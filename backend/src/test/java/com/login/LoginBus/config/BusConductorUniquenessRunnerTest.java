package com.login.LoginBus.config;

import com.login.LoginBus.transport.infra.BusJpaEntity;
import com.login.LoginBus.transport.infra.BusRepository;
import org.h2.jdbcx.JdbcDataSource;
import org.junit.jupiter.api.Test;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * Reproduces the scenario the reviewer flagged: a database that already has
 * the buses table (no unique constraint on conductor_id, as if created
 * before that constraint existed) with pre-existing duplicate assignments.
 * Confirms the runner both cleans up the duplicates and installs the
 * constraint, instead of relying solely on Hibernate's ddl-auto=update
 * (which silently gives up if duplicates are already present).
 */
class BusConductorUniquenessRunnerTest {

    private DataSource newDataSourceWithLegacyBusesTable() throws SQLException {
        JdbcDataSource ds = new JdbcDataSource();
        ds.setURL("jdbc:h2:mem:" + java.util.UUID.randomUUID() + ";DB_CLOSE_DELAY=-1");
        try (Connection conn = ds.getConnection(); Statement stmt = conn.createStatement()) {
            // No unique constraint on conductor_id - mirrors a table created
            // before that constraint was introduced.
            stmt.execute("CREATE TABLE buses (id BIGINT PRIMARY KEY AUTO_INCREMENT, "
                    + "plate_number VARCHAR(255) UNIQUE, conductor_id BIGINT)");
        }
        return ds;
    }

    private boolean hasUniqueConstraintOnConductorId(DataSource ds) throws SQLException {
        try (Connection conn = ds.getConnection();
             ResultSet rs = conn.getMetaData().getIndexInfo(null, null, "BUSES", true, false)) {
            while (rs.next()) {
                if ("CONDUCTOR_ID".equalsIgnoreCase(rs.getString("COLUMN_NAME"))) {
                    return true;
                }
            }
        }
        return false;
    }

    @Test
    void dedupesExistingDuplicatesAndInstallsTheConstraint() throws SQLException {
        DataSource dataSource = newDataSourceWithLegacyBusesTable();

        BusJpaEntity busA = new BusJpaEntity();
        busA.setId(1L);
        busA.setConductorId(10L);
        BusJpaEntity busB = new BusJpaEntity();
        busB.setId(2L);
        busB.setConductorId(10L); // duplicate assignment, pre-existing in the DB
        BusJpaEntity busC = new BusJpaEntity();
        busC.setId(3L);
        busC.setConductorId(20L);

        List<BusJpaEntity> saved = new ArrayList<>();
        BusRepository busRepository = mock(BusRepository.class);
        when(busRepository.findAll()).thenReturn(List.of(busA, busB, busC));
        when(busRepository.save(any(BusJpaEntity.class))).thenAnswer(inv -> {
            saved.add(inv.getArgument(0));
            return inv.getArgument(0);
        });

        assertThat(hasUniqueConstraintOnConductorId(dataSource)).isFalse();

        new BusConductorUniquenessRunner(busRepository, dataSource).run(null);

        // The newer duplicate (busB) was cleared; the older one (busA) kept.
        assertThat(saved).hasSize(1);
        assertThat(saved.get(0).getId()).isEqualTo(2L);
        assertThat(busB.getConductorId()).isNull();
        assertThat(busA.getConductorId()).isEqualTo(10L);

        assertThat(hasUniqueConstraintOnConductorId(dataSource)).isTrue();

        // Running again (e.g. next app restart) must not blow up now that
        // the constraint already exists.
        new BusConductorUniquenessRunner(busRepository, dataSource).run(null);
    }
}
