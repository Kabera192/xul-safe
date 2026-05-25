package com.login.LoginBus.transport.api;

import com.login.LoginBus.shared.api.ApiResponse;
import com.login.LoginBus.transport.app.TransportService;
import com.login.LoginBus.transport.domain.Route;
import com.login.LoginBus.transport.domain.RouteRequest;
import com.login.LoginBus.transport.domain.RouteRequestStatus;
import com.login.LoginBus.transport.infra.RouteRequestJpaEntity;
import com.login.LoginBus.transport.infra.RouteRequestRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * REST controller for route operations.
 * All endpoints use /api/v1 prefix for versioning.
 */
@RestController
@RequestMapping("/api/v1/routes")
@CrossOrigin(origins = "*")
public class RouteController {

    @Autowired
    private TransportService transportService;

    @Autowired
    private RouteRequestRepository routeRequestRepository;

    /**
     * Get assigned route for a child.
     * GET /api/v1/routes/child/{childId}
     *
     * @param childId The child ID
     * @return The child's assigned route, or null if none
     */
    @GetMapping("/child/{childId}")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getChildRoute(@PathVariable String childId) {
        Map<String, Object> childRoute = transportService.getChildRoute(childId);

        return ResponseEntity.ok(new ApiResponse<>(
            childRoute != null ? "Route retrieved successfully" : "No route assigned",
            childRoute
        ));
    }

    /**
     * Get route details for a child with selectable bus stops.
     * GET /api/v1/routes/child/{childId}/details
     *
     * Walks: child -> bus -> route -> route bus stops
     *
     * @param childId The child ID
     * @return Route details with assigned stop and selectable stops
     */
    @GetMapping("/child/{childId}/details")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getChildRouteDetails(
            @PathVariable String childId) {
        Map<String, Object> details = transportService.getChildRouteDetails(childId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Route details retrieved successfully",
            details
        ));
    }

    /**
     * Submit a custom bus stop request.
     * POST /api/v1/routes/requests
     *
     * Request body:
     * {
     *   "parentId": 1,
     *   "childId": "child-uuid",
     *   "latitude": -1.2345,
     *   "longitude": 36.7890,
     *   "address": "123 Main Street",
     *   "description": "Near the blue gate"
     * }
     *
     * @param request The route request data
     * @return Success message
     */
    @PostMapping("/requests")
    public ResponseEntity<ApiResponse<RouteRequest>> createRouteRequest(
            @RequestBody RouteRequest request) {

        // Validate required fields
        if (request.getParentId() == null) {
            throw new IllegalArgumentException("Parent ID is required");
        }
        if (request.getChildId() == null) {
            throw new IllegalArgumentException("Child ID is required");
        }
        if (request.getLatitude() == null || request.getLongitude() == null) {
            throw new IllegalArgumentException("Location coordinates are required");
        }

        if (request.getAddress() == null) {
            request.setAddress("");
        }
        if (request.getDescription() == null) {
            request.setDescription("");
        }

        RouteRequestJpaEntity entity = RouteRequestJpaEntity.fromDomain(request);
        RouteRequestJpaEntity saved = routeRequestRepository.save(entity);

        return ResponseEntity.ok(new ApiResponse<>(
            "Route request submitted successfully. Pending admin approval.",
            saved.toDomain()
        ));
    }

    /**
     * Get all route requests (admin).
     * GET /api/v1/routes/requests
     *
     * @return List of route requests
     */
    @GetMapping("/requests")
    public ResponseEntity<ApiResponse<List<RouteRequest>>> getAllRouteRequests() {
        List<RouteRequest> requests = routeRequestRepository.findAll().stream()
            .map(RouteRequestJpaEntity::toDomain)
            .collect(Collectors.toList());

        return ResponseEntity.ok(new ApiResponse<>(
            "Route requests retrieved successfully",
            requests
        ));
    }

    /**
     * Get a single route request by ID.
     * GET /api/v1/routes/requests/{requestId}
     *
     * @param requestId The request ID
     * @return The route request
     */
    @GetMapping("/requests/{requestId}")
    public ResponseEntity<ApiResponse<RouteRequest>> getRouteRequestById(@PathVariable Long requestId) {
        RouteRequestJpaEntity entity = routeRequestRepository.findById(requestId)
            .orElseThrow(() -> new IllegalArgumentException("Route request not found with ID: " + requestId));

        return ResponseEntity.ok(new ApiResponse<>(
            "Route request retrieved successfully",
            entity.toDomain()
        ));
    }

    /**
     * Update route request status (admin).
     * PUT /api/v1/routes/requests/{requestId}/status
     *
     * Request body:
     * {
     *   "status": "APPROVED" | "REJECTED" | "PENDING"
     * }
     *
     * @param requestId The request ID
     * @param statusData Status update payload
     * @return Updated route request
     */
    @PutMapping("/requests/{requestId}/status")
    public ResponseEntity<ApiResponse<RouteRequest>> updateRouteRequestStatus(
            @PathVariable Long requestId,
            @RequestBody Map<String, Object> statusData) {

        if (statusData.get("status") == null) {
            throw new IllegalArgumentException("status is required");
        }

        RouteRequestStatus nextStatus;
        try {
            String rawStatus = statusData.get("status").toString();
            nextStatus = RouteRequestStatus.valueOf(rawStatus.trim().toUpperCase(Locale.ROOT));
        } catch (Exception ex) {
            throw new IllegalArgumentException("Invalid status. Allowed values: PENDING, APPROVED, REJECTED");
        }

        // APPROVED requires a routeId — the admin picks which route the new stop belongs to
        if (nextStatus == RouteRequestStatus.APPROVED) {
            if (statusData.get("routeId") == null) {
                throw new IllegalArgumentException("routeId is required when approving a route request");
            }
            Long routeId = Long.valueOf(statusData.get("routeId").toString());
            RouteRequest result = transportService.approveRouteRequest(requestId, routeId);
            return ResponseEntity.ok(new ApiResponse<>(
                "Route request approved, bus stop created and assigned to child",
                result
            ));
        }

        RouteRequestJpaEntity entity = routeRequestRepository.findById(requestId)
            .orElseThrow(() -> new IllegalArgumentException("Route request not found with ID: " + requestId));

        entity.setStatus(nextStatus);
        RouteRequestJpaEntity saved = routeRequestRepository.save(entity);

        return ResponseEntity.ok(new ApiResponse<>(
            "Route request status updated successfully",
            saved.toDomain()
        ));
    }

    /**
     * Select a predefined bus stop for a child.
     * POST /api/v1/routes/select-bus-stop
     *
     * Request body:
     * {
     *   "parentId": "1",
     *   "childId": "child-uuid",
     *   "busStopId": "busstop-uuid"
     * }
     *
     * @param request The selection request
     * @return Success message
     */
    @PostMapping("/select-bus-stop")
    public ResponseEntity<ApiResponse<Map<String, Object>>> selectBusStop(
            @RequestBody Map<String, Object> request) {

        // Validate required fields
        if (request.get("parentId") == null) {
            throw new IllegalArgumentException("Parent ID is required");
        }
        if (request.get("childId") == null) {
            throw new IllegalArgumentException("Child ID is required");
        }
        if (request.get("busStopId") == null) {
            throw new IllegalArgumentException("Bus stop ID is required");
        }

        transportService.selectBusStop(
            request.get("childId").toString(),
            request.get("busStopId").toString()
        );

        return ResponseEntity.ok(new ApiResponse<>(
            "Bus stop selected successfully",
            request
        ));
    }

    // ========== Route CRUD Operations ==========

    /**
     * Get all routes.
     * GET /api/v1/routes
     *
     * @return List of all routes
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<Route>>> getAllRoutes() {
        List<Route> routes = transportService.getAllRoutes();
        return ResponseEntity.ok(new ApiResponse<>(
            "Routes retrieved successfully",
            routes
        ));
    }

    /**
     * Get route by ID.
     * GET /api/v1/routes/{routeId}
     *
     * @param routeId The route ID
     * @return The route
     */
    @GetMapping("/{routeId}")
    public ResponseEntity<ApiResponse<Route>> getRouteById(@PathVariable Long routeId) {
        Route route = transportService.getRouteById(routeId);
        if (route == null) {
            throw new IllegalArgumentException("Route not found with ID: " + routeId);
        }
        return ResponseEntity.ok(new ApiResponse<>(
            "Route retrieved successfully",
            route
        ));
    }

    /**
     * Create a new route.
     * POST /api/v1/routes
     *
     * @param route The route to create
     * @return Created route
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Route>> createRoute(@RequestBody Route route) {
        Route created = transportService.createRoute(route);
        return ResponseEntity.status(HttpStatus.CREATED).body(new ApiResponse<>(
            "Route created successfully",
            created
        ));
    }

    /**
     * Update a route.
     * PUT /api/v1/routes/{routeId}
     *
     * @param routeId The route ID
     * @param route Updated route data
     * @return Updated route
     */
    @PutMapping("/{routeId}")
    public ResponseEntity<ApiResponse<Route>> updateRoute(
            @PathVariable Long routeId,
            @RequestBody Route route) {
        Route updated = transportService.updateRoute(routeId, route);
        return ResponseEntity.ok(new ApiResponse<>(
            "Route updated successfully",
            updated
        ));
    }

    /**
     * Delete a route.
     * DELETE /api/v1/routes/{routeId}
     *
     * @param routeId The route ID
     * @return Success message
     */
    @DeleteMapping("/{routeId}")
    public ResponseEntity<ApiResponse<Void>> deleteRoute(@PathVariable Long routeId) {
        transportService.deleteRoute(routeId);
        return ResponseEntity.ok(new ApiResponse<>(
            "Route deleted successfully",
            null
        ));
    }
}
