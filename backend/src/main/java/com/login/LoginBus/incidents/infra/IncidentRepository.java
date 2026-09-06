package com.login.LoginBus.incidents.infra;

import com.login.LoginBus.incidents.domain.IncidentStatus;
import com.login.LoginBus.incidents.domain.IncidentType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository for Incident JPA entities.
 */
@Repository
public interface IncidentRepository extends JpaRepository<IncidentJpaEntity, Long> {

    List<IncidentJpaEntity> findAllByOrderByCreatedAtDesc();

    List<IncidentJpaEntity> findByStatusOrderByCreatedAtDesc(IncidentStatus status);

    List<IncidentJpaEntity> findByTypeOrderByCreatedAtDesc(IncidentType type);
}