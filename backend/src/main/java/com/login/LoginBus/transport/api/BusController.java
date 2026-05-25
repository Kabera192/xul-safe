package com.login.LoginBus.transport.api;

import com.login.LoginBus.shared.api.ApiResponse;
import com.login.LoginBus.transport.app.TransportService;
import com.login.LoginBus.transport.domain.Bus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * REST controller for bus operations.
 * All endpoints use /api/v1 prefix for versioning.
 */
@RestController
@RequestMapping("/api/v1/buses")
@CrossOrigin(origins = "*")
public class BusController {

    @Autowired
    private TransportService transportService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<Bus>>> getAllBuses() {
        List<Bus> buses = transportService.getAllBuses();
        return ResponseEntity.ok(new ApiResponse<>(
            "Buses retrieved successfully",
            buses
        ));
    }

    @GetMapping("/{busId}")
    public ResponseEntity<ApiResponse<Bus>> getBus(@PathVariable Long busId) {
        Bus bus = transportService.getBusById(busId);
        if (bus == null) {
            throw new IllegalArgumentException("Bus not found with ID: " + busId);
        }
        return ResponseEntity.ok(new ApiResponse<>(
            "Bus retrieved successfully",
            bus
        ));
    }

    @GetMapping("/plate/{plateNumber}")
    public ResponseEntity<ApiResponse<Bus>> getBusByPlate(@PathVariable String plateNumber) {
        Bus bus = transportService.getBusByPlateNumber(plateNumber);
        if (bus == null) {
            throw new IllegalArgumentException("Bus not found with plate: " + plateNumber);
        }
        return ResponseEntity.ok(new ApiResponse<>(
            "Bus retrieved successfully",
            bus
        ));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Bus>> createBus(@RequestBody Bus bus) {
        Bus created = transportService.createBus(bus);
        return ResponseEntity.status(HttpStatus.CREATED).body(new ApiResponse<>(
            "Bus created successfully",
            created
        ));
    }

    @PutMapping("/{busId}")
    public ResponseEntity<ApiResponse<Bus>> updateBus(@PathVariable Long busId, @RequestBody Bus bus) {
        Bus updated = transportService.updateBus(busId, bus);
        return ResponseEntity.ok(new ApiResponse<>(
            "Bus updated successfully",
            updated
        ));
    }

    @DeleteMapping("/{busId}")
    public ResponseEntity<ApiResponse<Void>> deleteBus(@PathVariable Long busId) {
        transportService.deleteBus(busId);
        return ResponseEntity.ok(new ApiResponse<>(
            "Bus deleted successfully",
            null
        ));
    }

    /**
     * Get the bus and conductor assigned to a parent's children.
     * GET /api/v1/buses/parent/{parentId}/assigned
     */
    @GetMapping("/parent/{parentId}/assigned")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getAssignedBusForParent(
            @PathVariable Long parentId) {
        Map<String, Object> details = transportService.getAssignedBusDetailsForParent(parentId);
        if (details.isEmpty()) {
            return ResponseEntity.ok(new ApiResponse<>("No bus assigned to parent's children", null));
        }
        return ResponseEntity.ok(new ApiResponse<>(
            "Assigned bus details retrieved successfully",
            details
        ));
    }
}
