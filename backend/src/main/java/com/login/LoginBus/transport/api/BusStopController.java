package com.login.LoginBus.transport.api;

import com.login.LoginBus.shared.api.ApiResponse;
import com.login.LoginBus.transport.app.TransportService;
import com.login.LoginBus.transport.domain.BusStop;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * REST controller for bus stop operations.
 * All endpoints use /api/v1 prefix for versioning.
 */
@RestController
@RequestMapping("/api/v1/bus-stops")
@CrossOrigin(origins = "*")
public class BusStopController {

    @Autowired
    private TransportService transportService;

    /**
     * Get all available bus stops.
     * GET /api/v1/bus-stops
     *
     * @return List of all bus stops
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<BusStop>>> getAllBusStops() {
        List<BusStop> busStops = transportService.getAllBusStops();

        return ResponseEntity.ok(new ApiResponse<>(
            "Bus stops retrieved successfully",
            busStops
        ));
    }

    /**
     * Get a specific bus stop by ID.
     * GET /api/v1/bus-stops/{busStopId}
     *
     * @param busStopId The bus stop ID
     * @return The bus stop
     */
    @GetMapping("/{busStopId}")
    public ResponseEntity<ApiResponse<BusStop>> getBusStop(@PathVariable String busStopId) {
        BusStop busStop = transportService.getBusStopById(busStopId);

        if (busStop == null) {
            throw new IllegalArgumentException("Bus stop not found with ID: " + busStopId);
        }

        return ResponseEntity.ok(new ApiResponse<>(
            "Bus stop retrieved successfully",
            busStop
        ));
    }

    /**
     * Get bus stops for a specific route.
     * GET /api/v1/bus-stops/route/{routeId}
     *
     * @param routeId The route ID
     * @return List of bus stops for the route
     */
    @GetMapping("/route/{routeId}")
    public ResponseEntity<ApiResponse<List<BusStop>>> getRouteStops(@PathVariable Long routeId) {
        List<BusStop> busStops = transportService.getRouteStops(routeId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Route bus stops retrieved successfully",
            busStops
        ));
    }

    /**
     * Create a new bus stop and associate it with a route.
     * POST /api/v1/bus-stops
     *
     * @param busStop The bus stop data (must include routeId)
     * @return The created bus stop
     */
    @PostMapping
    public ResponseEntity<ApiResponse<BusStop>> createBusStop(@RequestBody BusStop busStop) {
        BusStop created = transportService.createBusStop(busStop);

        return ResponseEntity.status(HttpStatus.CREATED).body(new ApiResponse<>(
            "Bus stop created successfully",
            created
        ));
    }

    /**
     * Update an existing bus stop.
     * PUT /api/v1/bus-stops/{busStopId}
     *
     * @param busStopId The bus stop ID
     * @param busStop   Updated fields
     * @return The updated bus stop
     */
    @PutMapping("/{busStopId}")
    public ResponseEntity<ApiResponse<BusStop>> updateBusStop(
            @PathVariable String busStopId,
            @RequestBody BusStop busStop) {
        BusStop updated = transportService.updateBusStop(busStopId, busStop);

        return ResponseEntity.ok(new ApiResponse<>(
            "Bus stop updated successfully",
            updated
        ));
    }

    /**
     * Delete a bus stop.
     * DELETE /api/v1/bus-stops/{busStopId}
     *
     * @param busStopId The bus stop ID
     */
    @DeleteMapping("/{busStopId}")
    public ResponseEntity<ApiResponse<Void>> deleteBusStop(@PathVariable String busStopId) {
        transportService.deleteBusStop(busStopId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Bus stop deleted successfully",
            null
        ));
    }
}
