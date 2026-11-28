package com.login.LoginBus.config;

import com.login.LoginBus.transport.infra.BusJpaEntity;
import com.login.LoginBus.transport.infra.BusRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * One-time cleanup + safety net for the buses.conductor_id unique
 * constraint added alongside the double-assignment fix.
 *
 * Hibernate's ddl-auto=update only *attempts* to add that constraint; if
 * duplicate conductor_id rows already existed from before the constraint
 * was introduced, the ALTER TABLE fails and Hibernate just logs a warning
 * and keeps starting up - silently leaving the database unprotected. This
 * runner removes any existing duplicates (keeping the oldest assignment)
 * and then adds the constraint itself if it's still missing, so the
 * protection is actually in place regardless of what Hibernate managed to
 * do on its own.
 *
 * Idempotent and cheap once there's nothing left to fix, so it's safe to
 * run on every startup rather than as a manual, one-off migration.
 */
@Component
public class BusConductorUniquenessRunner implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(BusConductorUniquenessRunner.class);

    private final BusRepository busRepository;
    private final DataSource dataSource;

    public BusConductorUniquenessRunner(BusRepository busRepository, DataSource dataSource) {
        this.busRepository = busRepository;
        this.dataSource = dataSource;
    }

    @Override
    public void run(ApplicationArguments args) {
        dedupeExistingAssignments();
        ensureUniqueConstraint();
    }

    private void dedupeExistingAssignments() {
        List<BusJpaEntity> buses = busRepository.findAll();
        Map<Long, List<BusJpaEntity>> byConductor = buses.stream()
                .filter(b -> b.getConductorId() != null)
                .collect(Collectors.groupingBy(BusJpaEntity::getConductorId));

        for (Map.Entry<Long, List<BusJpaEntity>> entry : byConductor.entrySet()) {
            List<BusJpaEntity> assigned = entry.getValue();
            if (assigned.size() <= 1) continue;

            assigned.sort(Comparator.comparing(BusJpaEntity::getId));
            BusJpaEntity keep = assigned.get(0);
            for (BusJpaEntity extra : assigned.subList(1, assigned.size())) {
                try {
                    extra.setConductorId(null);
                    busRepository.save(extra);
                    log.warn("Bus id={} and bus id={} were both assigned to conductor id={}; "
                                    + "cleared the assignment on bus id={} (kept the older one).",
                            keep.getId(), extra.getId(), entry.getKey(), extra.getId());
                } catch (Exception e) {
                    log.warn("Could not clear the duplicate conductor assignment on bus id={} - "
                            + "left as-is for manual review.", extra.getId(), e);
                }
            }
        }
    }

    private void ensureUniqueConstraint() {
        try (Connection conn = dataSource.getConnection()) {
            if (hasUniqueIndexOnConductorId(conn)) {
                return;
            }
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("ALTER TABLE buses ADD CONSTRAINT uk_buses_conductor_id UNIQUE (conductor_id)");
                log.info("Added the missing unique constraint on buses.conductor_id.");
            }
        } catch (SQLException e) {
            log.warn("Could not verify/add the unique constraint on buses.conductor_id - "
                    + "concurrent double-assignment is not protected at the database level "
                    + "until this is resolved.", e);
        }
    }

    /**
     * Uses JDBC metadata (portable across Postgres and the H2 test database)
     * rather than a dialect-specific catalog query, and tries a couple of
     * identifier casings since unquoted table names fold differently across
     * databases.
     */
    private boolean hasUniqueIndexOnConductorId(Connection conn) throws SQLException {
        DatabaseMetaData meta = conn.getMetaData();
        for (String tableName : new String[] {"buses", "BUSES", "Buses"}) {
            Map<String, List<String>> columnsByIndex = new LinkedHashMap<>();
            boolean tableFound = false;
            try (ResultSet rs = meta.getIndexInfo(null, null, tableName, true, false)) {
                while (rs.next()) {
                    tableFound = true;
                    String indexName = rs.getString("INDEX_NAME");
                    String columnName = rs.getString("COLUMN_NAME");
                    if (indexName == null || columnName == null) continue;
                    columnsByIndex.computeIfAbsent(indexName, k -> new ArrayList<>()).add(columnName);
                }
            }
            if (!tableFound) continue;
            return columnsByIndex.values().stream()
                    .anyMatch(cols -> cols.size() == 1 && cols.get(0).equalsIgnoreCase("conductor_id"));
        }
        // Couldn't read index metadata under any casing - assume the
        // constraint is missing so we attempt to add it; if the table
        // genuinely doesn't exist, that ALTER will fail loudly instead.
        return false;
    }
}
