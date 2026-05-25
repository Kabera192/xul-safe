package com.login.LoginBus.accounts.infra;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository for Conductor JPA entities.
 * This is infrastructure layer - handles database operations only.
 */
@Repository
public interface ConductorRepository extends JpaRepository<ConductorJpaEntity, Long> {

    /**
     * Find a conductor by phone number.
     *
     * @param phoneNumber The phone number
     * @return Optional containing conductor if found
     */
    Optional<ConductorJpaEntity> findByPhoneNumber(String phoneNumber);

    /**
     * Find all active conductors.
     *
     * @return List of active conductors
     */
    List<ConductorJpaEntity> findByStatus(com.login.LoginBus.accounts.domain.ConductorStatus status);

    Optional<ConductorJpaEntity> findByUserId(Long userId);
}
