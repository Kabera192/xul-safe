package com.login.LoginBus.transport.infra;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository for BusTracking JPA entities.
 * This is infrastructure layer - handles database operations only.
 */
@Repository
public interface BusTrackingRepository extends JpaRepository<BusTrackingJpaEntity, String> {

    /**
     * Find the latest bus tracking for a specific child.
     */
    @Query("SELECT bt FROM BusTrackingJpaEntity bt WHERE bt.childId = :childId ORDER BY bt.updatedAt DESC LIMIT 1")
    BusTrackingJpaEntity findLatestByChildId(@Param("childId") String childId);

    /**
     * Find the latest bus tracking for a specific route.
     */
    @Query("SELECT bt FROM BusTrackingJpaEntity bt WHERE bt.routeId = :routeId ORDER BY bt.updatedAt DESC LIMIT 1")
    BusTrackingJpaEntity findLatestByRouteId(@Param("routeId") Long routeId);

    /**
     * Find active bus tracking for a specific child.
     * Active means status is not NOT_IN_ROUTE.
     */
    @Query("SELECT bt FROM BusTrackingJpaEntity bt WHERE bt.childId = :childId AND bt.status <> 'NOT_IN_ROUTE' ORDER BY bt.updatedAt DESC LIMIT 1")
    Optional<BusTrackingJpaEntity> findActiveBusTrackingByChildId(@Param("childId") String childId);

    /**
     * Find active bus tracking for a specific route.
     * Active means status is not NOT_IN_ROUTE.
     */
    @Query("SELECT bt FROM BusTrackingJpaEntity bt WHERE bt.routeId = :routeId AND bt.status <> 'NOT_IN_ROUTE' ORDER BY bt.updatedAt DESC LIMIT 1")
    Optional<BusTrackingJpaEntity> findActiveBusTrackingByRouteId(@Param("routeId") Long routeId);

    /**
     * Find active bus tracking for a specific conductor.
     * Active means status is not NOT_IN_ROUTE.
     */
    @Query("SELECT bt FROM BusTrackingJpaEntity bt WHERE bt.conductorId = :conductorId AND bt.status <> 'NOT_IN_ROUTE' ORDER BY bt.updatedAt DESC LIMIT 1")
    Optional<BusTrackingJpaEntity> findActiveBusTrackingByConductorId(@Param("conductorId") Long conductorId);

    /**
     * Find active bus tracking for a specific bus.
     * Used by features that need to know whether a bus is currently
     * involved in an active transport operation.
     */
    @Query("SELECT bt FROM BusTrackingJpaEntity bt WHERE bt.busId = :busId AND bt.status <> 'NOT_IN_ROUTE' ORDER BY bt.updatedAt DESC LIMIT 1")
    Optional<BusTrackingJpaEntity> findActiveBusTrackingByBusId(@Param("busId") Long busId);
}