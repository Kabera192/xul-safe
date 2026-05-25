package com.login.LoginBus.transport.infra;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository for BusStop JPA entities.
 * This is infrastructure layer - handles database operations only.
 */
@Repository
public interface BusStopRepository extends JpaRepository<BusStopJpaEntity, String> {

    /**
     * Find all bus stops ordered by name.
     *
     * @return List of all bus stops
     */
    List<BusStopJpaEntity> findAllByOrderByNameAsc();

    /**
     * Find bus stops by route ID, ordered by stop order.
     *
     * @param routeId The route ID
     * @return List of bus stops for the route
     */
    List<BusStopJpaEntity> findByRouteIdOrderByStopOrderAsc(Long routeId);
}
