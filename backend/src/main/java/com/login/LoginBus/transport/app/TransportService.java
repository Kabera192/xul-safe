package com.login.LoginBus.transport.app;

import com.login.LoginBus.transport.domain.*;
import java.util.List;
import java.util.Map;

/**
 * Service interface for Transport module.
 * Defines all business operations for buses, tracking, journeys, and routes.
 */
public interface TransportService {

    // ========== Bus Tracking Operations ==========

    /**
     * Get active bus tracking for a specific child.
     *
     * @param childId The child ID
     * @return The active tracking, or null if no active tracking
     */
    BusTracking getActiveBusTrackingForChild(String childId);

    /**
     * Get active bus tracking for a specific route.
     *
     * @param routeId The route ID
     * @return The active tracking, or null if no active tracking
     */
    BusTracking getActiveBusTrackingForRoute(Long routeId);

    /**
     * Start a new journey/tracking session.
     *
     * @param journeyData Map containing journey details
     * @return The created BusTracking
     */
    BusTracking startJourney(Map<String, Object> journeyData);

    /**
     * Update bus location.
     *
     * @param trackingId The tracking ID
     * @param latitude New latitude
     * @param longitude New longitude
     * @return Updated BusTracking
     */
    BusTracking updateLocation(String trackingId, Double latitude, Double longitude);

    /**
     * Update bus status.
     *
     * @param trackingId The tracking ID
     * @param status New status
     * @return Updated BusTracking
     */
    BusTracking updateStatus(String trackingId, String status);

    /**
     * End a journey/tracking session.
     *
     * @param trackingId The tracking ID
     */
    void endJourney(String trackingId);

    // ========== Route & Stop Operations ==========

    /**
     * Get all bus stops for a specific route.
     *
     * @param routeId The route ID
     * @return List of bus stops in sequence order
     */
    List<BusStop> getRouteStops(Long routeId);

    /**
     * Get all available bus stops.
     *
     * @return List of all bus stops
     */
    List<BusStop> getAllBusStops();

    /**
     * Get a specific bus stop by ID.
     *
     * @param busStopId The bus stop ID
     * @return The bus stop, or null if not found
     */
    BusStop getBusStopById(String busStopId);

    /**
     * Get assigned route/bus stop for a child.
     *
     * @param childId The child ID
     * @return Map containing route info, or null if no route assigned
     */
    Map<String, Object> getChildRoute(String childId);

    /**
     * Get full parent-facing route details for a child.
     * Walks the chain: child -> bus -> route -> bus stops.
     *
     * @param childId The child ID
     * @return Map containing route, assigned stop, and selectable stops
     */
    Map<String, Object> getChildRouteDetails(String childId);

    /**
     * Assign a predefined bus stop to a child.
     * Validates the stop belongs to the route assigned to the child's bus.
     *
     * @param childId   The child ID
     * @param busStopId The predefined bus stop ID
     */
    void selectBusStop(String childId, String busStopId);

    /**
     * Approve a custom route request: creates a new bus stop from the request
     * location, links it to the given route, and updates the child's assignment.
     *
     * @param requestId The route request ID
     * @param routeId   The route the new bus stop should belong to
     * @return The updated RouteRequest
     */
    RouteRequest approveRouteRequest(Long requestId, Long routeId);

    // ========== Journey Operations ==========

    /**
     * Get all journeys for specific children.
     *
     * @param childIds List of child IDs
     * @return List of journeys
     */
    List<Journey> getJourneysByChildIds(List<String> childIds);

    /**
     * Get journey summary for parent (includes monthly count).
     *
     * @param childIds List of child IDs
     * @return Map with journeys and count
     */
    Map<String, Object> getJourneySummaryForParent(List<String> childIds);

    /**
     * Create sample journey data for testing.
     *
     * @param childIds List of child IDs
     */
    void createSampleJourneys(List<String> childIds);

    /**
     * Get all journeys (admin).
     *
     * @return List of all journeys
     */
    List<Journey> getAllJourneys();

    /**
     * Get journeys filtered by date range (admin).
     *
     * @param startDate Start date (yyyy-MM-dd)
     * @param endDate End date (yyyy-MM-dd)
     * @return List of journeys in date range
     */
    List<Journey> getJourneysByDateRange(String startDate, String endDate);

    /**
     * Get weekly attendance data for admin dashboard.
     * Returns attendance grouped by child with daily pickup/dropoff status.
     *
     * @param weekStartDate Start date of the week (yyyy-MM-dd, should be Monday)
     * @return List of attendance records grouped by child
     */
    List<Map<String, Object>> getWeeklyAttendance(String weekStartDate);

    // ========== Parent-Facing Bus Operations ==========

    /**
     * Get the bus and conductor details assigned to a parent's children.
     * Walks the chain: parent → children → bus → conductor.
     *
     * @param parentId The parent user ID
     * @return Map with "bus" and "conductor" keys, or empty map if nothing assigned
     */
    Map<String, Object> getAssignedBusDetailsForParent(Long parentId);

    // ========== Bus Operations ==========

    /**
     * Get bus by ID.
     *
     * @param busId The bus ID
     * @return The bus, or null if not found
     */
    Bus getBusById(Long busId);

    /**
     * Get bus by plate number.
     *
     * @param plateNumber The plate number
     * @return The bus, or null if not found
     */
    Bus getBusByPlateNumber(String plateNumber);

    /**
     * Get all buses (admin).
     *
     * @return List of buses
     */
    List<Bus> getAllBuses();

    /**
     * Create a new bus.
     *
     * @param bus The bus to create
     * @return The created bus
     */
    Bus createBus(Bus bus);

    /**
     * Update an existing bus.
     *
     * @param busId The bus ID
     * @param bus The updated bus data
     * @return The updated bus
     */
    Bus updateBus(Long busId, Bus bus);

    /**
     * Delete a bus.
     *
     * @param busId The bus ID
     */
    void deleteBus(Long busId);

    // ========== Route Operations ==========

    /**
     * Get all routes.
     *
     * @return List of all routes
     */
    List<Route> getAllRoutes();

    /**
     * Get route by ID.
     *
     * @param routeId The route ID
     * @return The route, or null if not found
     */
    Route getRouteById(Long routeId);

    /**
     * Create a new route.
     *
     * @param route The route to create
     * @return The created route
     */
    Route createRoute(Route route);

    /**
     * Update an existing route.
     *
     * @param routeId The route ID
     * @param route The updated route data
     * @return The updated route
     */
    Route updateRoute(Long routeId, Route route);

    /**
     * Delete a route.
     *
     * @param routeId The route ID
     */
    void deleteRoute(Long routeId);
}
