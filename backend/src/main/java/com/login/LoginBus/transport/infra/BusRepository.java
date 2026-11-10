package com.login.LoginBus.transport.infra;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
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

    List<BusJpaEntity> findByRouteId(Long routeId);

    /**
     * Locks the bus row for the rest of the caller's transaction, so two
     * concurrent capacity checks against the same bus can't both read "one
     * seat left" and both proceed to fill it.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select b from BusJpaEntity b where b.id = :id")
    Optional<BusJpaEntity> findByIdForUpdate(@Param("id") Long id);
}
