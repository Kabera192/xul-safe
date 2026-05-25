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
     *
     * @param childId The child ID
     * @return The latest tracking, or null if not found
     */
    @Query("SELECT bt FROM BusTrackingJpaEntity bt WHERE bt.childId = :childId ORDER BY bt.updatedAt DESC LIMIT 1")
    BusTrackingJpaEntity findLatestByChildId(@Param("childId") String childId);

    /**
     * Find the latest bus tracking for a specific route.
     *
     * @param routeId The route ID
     * @return The latest tracking, or null if not found
     */
    @Query("SELECT bt FROM BusTrackingJpaEntity bt WHERE bt.routeId = :routeId ORDER BY bt.updatedAt DESC LIMIT 1")
    BusTrackingJpaEntity findLatestByRouteId(@Param("routeId") Long routeId);

    /**
     * Find active bus tracking for a specific child.
     * Active means status is not NOT_IN_ROUTE.
     *
     * @param childId The child ID
     * @return Optional containing active tracking, or empty
     */
    @Query("SELECT bt FROM BusTrackingJpaEntity bt WHERE bt.childId = :childId AND bt.status <> 'NOT_IN_ROUTE' ORDER BY bt.updatedAt DESC LIMIT 1")
    Optional<BusTrackingJpaEntity> findActiveBusTrackingByChildId(@Param("childId") String childId);

    /**
     * Find active bus tracking for a specific route.
     * Active means status is not NOT_IN_ROUTE.
     *
     * @param routeId The route ID
     * @return Optional containing active tracking, or empty
     */
    @Query("SELECT bt FROM BusTrackingJpaEntity bt WHERE bt.routeId = :routeId AND bt.status <> 'NOT_IN_ROUTE' ORDER BY bt.updatedAt DESC LIMIT 1")
    Optional<BusTrackingJpaEntity> findActiveBusTrackingByRouteId(@Param("routeId") Long routeId);

    /**
     * Find active bus tracking for a specific conductor.
     * Active means status is not NOT_IN_ROUTE.
     *
     * @param conductorId The conductor ID
     * @return Optional containing active tracking, or empty
     */
    @Query("SELECT bt FROM BusTrackingJpaEntity bt WHERE bt.conductorId = :conductorId AND bt.status <> 'NOT_IN_ROUTE' ORDER BY bt.updatedAt DESC LIMIT 1")
    Optional<BusTrackingJpaEntity> findActiveBusTrackingByConductorId(@Param("conductorId") Long conductorId);
}
