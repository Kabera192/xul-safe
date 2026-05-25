package com.login.LoginBus.transport.infra;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository for Bus JPA entities.
 * This is infrastructure layer - handles database operations only.
 */
@Repository
public interface BusRepository extends JpaRepository<BusJpaEntity, Long> {

    BusJpaEntity findByPlateNumber(String plateNumber);

    Optional<BusJpaEntity> findByDriverId(Long driverId);

    Optional<BusJpaEntity> findByConductorId(Long conductorId);
}
