package com.login.LoginBus.transport.app;

import com.login.LoginBus.transport.domain.BusTracking;
import com.login.LoginBus.transport.domain.BusStop;
import com.login.LoginBus.transport.domain.Journey;
import com.login.LoginBus.transport.domain.Bus;

import java.util.List;

/**
 * Public service interface for Transport module.
 * Other modules use this interface to access bus tracking, routes, and journey information.
 *
 * This is the ONLY way other modules should interact with the transport module.
 */
public interface TransportPublicService {

    /**
     * Get active bus tracking for a specific child.
     *
     * @param childId The child ID
     * @return The active bus tracking, or null if no active tracking
     */
    BusTracking getActiveBusTracking(String childId);

    /**
     * Get all bus stops for a specific route.
     *
     * @param routeId The route ID
     * @return List of bus stops in sequence order
     */
    List<BusStop> getRouteStops(Long routeId);

    /**
     * Get a specific journey by ID.
     *
     * @param journeyId The journey ID
     * @return The journey, or null if not found
     */
    Journey getJourneyById(Long journeyId);

    /**
     * Get all journeys for specific children.
     *
     * @param childIds List of child IDs
     * @return List of journeys for those children
     */
    List<Journey> getJourneysByChildIds(List<String> childIds);

    /**
     * Get bus by ID.
     *
     * @param busId The bus ID
     * @return The bus, or null if not found
     */
    Bus getBusById(Long busId);
}
