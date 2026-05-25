package com.login.LoginBus.transport.api;

import com.login.LoginBus.shared.api.ApiResponse;
import com.login.LoginBus.transport.app.TransportService;
import com.login.LoginBus.transport.domain.BusStop;
import org.springframework.beans.factory.annotation.Autowired;
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
}
