package com.login.LoginBus.accounts.api;

import com.login.LoginBus.accounts.app.DriverAdminService;
import com.login.LoginBus.shared.api.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for Driver admin operations.
 *
 * A "Driver" is both a user account (role=DRIVER, used to log into the Flutter app)
 * AND a conductor profile (conductors table, used by /me/* endpoints and Flutter's bus data).
 * These are always created and deleted together — they are the same person.
 *
 * GET    /api/v1/drivers         — list all drivers
 * POST   /api/v1/drivers         — create user(DRIVER) + conductor profile atomically
 * GET    /api/v1/drivers/{id}    — get by conductor profile id
 * PUT    /api/v1/drivers/{id}    — update driver
 * DELETE /api/v1/drivers/{id}    — delete driver (user + conductor profile)
 */
@RestController
@RequestMapping("/api/v1/drivers")
@CrossOrigin(origins = "*")
public class DriverAdminController {

    private final DriverAdminService driverAdminService;

    public DriverAdminController(DriverAdminService driverAdminService) {
        this.driverAdminService = driverAdminService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<DriverAdminDto>>> getAllDrivers() {
        List<DriverAdminDto> drivers = driverAdminService.getAllDrivers();
        return ResponseEntity.ok(new ApiResponse<>("Drivers retrieved successfully", drivers));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<DriverAdminDto>> getDriverById(@PathVariable Long id) {
        DriverAdminDto driver = driverAdminService.getDriverById(id);
        return ResponseEntity.ok(new ApiResponse<>("Driver retrieved successfully", driver));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<DriverAdminDto>> createDriver(@RequestBody DriverAdminDto dto) {
        DriverAdminDto created = driverAdminService.createDriver(dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new ApiResponse<>("Driver created successfully", created));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<DriverAdminDto>> updateDriver(
            @PathVariable Long id,
            @RequestBody DriverAdminDto dto) {
        DriverAdminDto updated = driverAdminService.updateDriver(id, dto);
        return ResponseEntity.ok(new ApiResponse<>("Driver updated successfully", updated));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteDriver(@PathVariable Long id) {
        driverAdminService.deleteDriver(id);
        return ResponseEntity.ok(new ApiResponse<>("Driver deleted successfully", null));
    }
}
