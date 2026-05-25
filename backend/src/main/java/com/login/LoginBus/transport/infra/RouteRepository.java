package com.login.LoginBus.transport.infra;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repository for Route JPA entities.
 */
@Repository
public interface RouteRepository extends JpaRepository<RouteJpaEntity, Long> {
}
