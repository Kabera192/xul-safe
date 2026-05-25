package com.login.LoginBus.transport.api;

import com.login.LoginBus.shared.api.ApiResponse;
import com.login.LoginBus.transport.app.TransportService;
import com.login.LoginBus.transport.domain.BusTracking;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * REST controller for bus tracking operations.
 * All endpoints use /api/v1 prefix for versioning.
 */
@RestController
@RequestMapping("/api/v1/bus-tracking")
@CrossOrigin(origins = "*")
public class BusTrackingController {

    @Autowired
    private TransportService transportService;

    /**
     * Get active bus tracking for a specific child.
     * GET /api/v1/bus-tracking/child/{childId}
     *
     * @param childId The child ID
     * @return Active bus tracking or null if no active journey
     */
    @GetMapping("/child/{childId}")
    public ResponseEntity<ApiResponse<BusTracking>> getActiveBusTrackingForChild(@PathVariable String childId) {
        BusTracking tracking = transportService.getActiveBusTrackingForChild(childId);

        if (tracking != null) {
            return ResponseEntity.ok(new ApiResponse<>(
                "Active bus tracking found",
                tracking
            ));
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ApiResponse<>(
                "No active journey found",
                null
            ));
        }
    }

    /**
     * Get active bus tracking for a specific route.
     * GET /api/v1/bus-tracking/route/{routeId}
     *
     * @param routeId The route ID
     * @return Active bus tracking or null if no active journey
     */
    @GetMapping("/route/{routeId}")
    public ResponseEntity<ApiResponse<BusTracking>> getActiveBusTrackingForRoute(@PathVariable Long routeId) {
        BusTracking tracking = transportService.getActiveBusTrackingForRoute(routeId);

        if (tracking != null) {
            return ResponseEntity.ok(new ApiResponse<>(
                "Active bus tracking found for route",
                tracking
            ));
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(new ApiResponse<>(
                "No active journey for this route",
                null
            ));
        }
    }

    /**
     * Start a new journey (Conductor function).
     * POST /api/v1/bus-tracking/start
     *
     * Request body:
     * {
     *   "tripType": "MORNING_PICKUP" or "AFTERNOON_DROPOFF",
     *   "conductorId": 1,
     *   "busId": 1,
     *   "routeId": 1,
     *   "latitude": -1.9441,
     *   "longitude": 30.0619
     * }
     *
     * @param journeyData Journey start data
     * @return Created bus tracking
     */
    @PostMapping("/start")
    public ResponseEntity<ApiResponse<BusTracking>> startJourney(@RequestBody Map<String, Object> journeyData) {
        // Validate required fields
        if (!journeyData.containsKey("tripType") ||
            !journeyData.containsKey("conductorId") ||
            !journeyData.containsKey("busId")) {
            throw new IllegalArgumentException("tripType, conductorId, and busId are required");
        }

        BusTracking tracking = transportService.startJourney(journeyData);

        return ResponseEntity.status(HttpStatus.CREATED).body(new ApiResponse<>(
            "Journey started successfully",
            tracking
        ));
    }

    /**
     * Update bus location (Conductor function - called periodically).
     * PUT /api/v1/bus-tracking/{trackingId}/location
     *
     * Request body:
     * {
     *   "latitude": -1.9441,
     *   "longitude": 30.0619
     * }
     *
     * @param trackingId The tracking ID
     * @param locationData Location data
     * @return Updated bus tracking
     */
    @PutMapping("/{trackingId}/location")
    public ResponseEntity<ApiResponse<BusTracking>> updateLocation(
            @PathVariable String trackingId,
            @RequestBody Map<String, Object> locationData) {

        if (!locationData.containsKey("latitude") || !locationData.containsKey("longitude")) {
            throw new IllegalArgumentException("latitude and longitude are required");
        }

        Double latitude = Double.valueOf(locationData.get("latitude").toString());
        Double longitude = Double.valueOf(locationData.get("longitude").toString());

        BusTracking tracking = transportService.updateLocation(trackingId, latitude, longitude);

        return ResponseEntity.ok(new ApiResponse<>(
            "Location updated successfully",
            tracking
        ));
    }

    /**
     * Update journey status (Conductor function).
     * PUT /api/v1/bus-tracking/{trackingId}/status
     *
     * Request body:
     * {
     *   "status": "GOING_TO_SCHOOL" | "AT_SCHOOL" | "DROPPING_OFF_CHILDREN"
     * }
     *
     * @param trackingId The tracking ID
     * @param statusData Status data
     * @return Updated bus tracking
     */
    @PutMapping("/{trackingId}/status")
    public ResponseEntity<ApiResponse<BusTracking>> updateStatus(
            @PathVariable String trackingId,
            @RequestBody Map<String, Object> statusData) {

        if (!statusData.containsKey("status")) {
            throw new IllegalArgumentException("status is required");
        }

        String status = statusData.get("status").toString();
        BusTracking tracking = transportService.updateStatus(trackingId, status);

        return ResponseEntity.ok(new ApiResponse<>(
            "Status updated successfully",
            tracking
        ));
    }

    /**
     * End journey (Conductor function).
     * POST /api/v1/bus-tracking/{trackingId}/end
     *
     * @param trackingId The tracking ID
     * @return Success message
     */
    @PostMapping("/{trackingId}/end")
    public ResponseEntity<ApiResponse<Void>> endJourney(@PathVariable String trackingId) {
        transportService.endJourney(trackingId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Journey ended successfully",
            null
        ));
    }
}
