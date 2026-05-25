package com.login.LoginBus.accounts.api;

import com.login.LoginBus.accounts.app.AccountsService;
import com.login.LoginBus.accounts.domain.Conductor;
import com.login.LoginBus.shared.api.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for conductor operations.
 * All endpoints use /api/v1 prefix for versioning.
 */
@RestController
@RequestMapping("/api/v1/conductors")
@CrossOrigin(origins = "*")
public class ConductorController {

    @Autowired
    private AccountsService accountsService;

    /**
     * Get all conductors.
     * GET /api/v1/conductors
     *
     * @return List of conductors
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<Conductor>>> getAllConductors() {
        List<Conductor> conductors = accountsService.getAllConductors();
        return ResponseEntity.ok(new ApiResponse<>(
            "Conductors retrieved successfully",
            conductors
        ));
    }

    /**
     * Get conductor by ID.
     * GET /api/v1/conductors/{conductorId}
     *
     * @param conductorId The conductor ID
     * @return Conductor
     */
    @GetMapping("/{conductorId}")
    public ResponseEntity<ApiResponse<Conductor>> getConductorById(@PathVariable Long conductorId) {
        Conductor conductor = accountsService.getConductorById(conductorId);
        if (conductor == null) {
            throw new IllegalArgumentException("Conductor not found with ID: " + conductorId);
        }
        return ResponseEntity.ok(new ApiResponse<>(
            "Conductor retrieved successfully",
            conductor
        ));
    }

    /**
     * Create a new conductor.
     * POST /api/v1/conductors
     *
     * @param conductor The conductor to create
     * @return Created conductor
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Conductor>> createConductor(@RequestBody Conductor conductor) {
        Conductor created = accountsService.createConductor(conductor);
        return ResponseEntity.ok(new ApiResponse<>(
            "Conductor created successfully",
            created
        ));
    }

    /**
     * Update a conductor.
     * PUT /api/v1/conductors/{conductorId}
     *
     * @param conductorId The conductor ID
     * @param conductor Updated conductor data
     * @return Updated conductor
     */
    @PutMapping("/{conductorId}")
    public ResponseEntity<ApiResponse<Conductor>> updateConductor(
            @PathVariable Long conductorId,
            @RequestBody Conductor conductor) {
        Conductor updated = accountsService.updateConductor(conductorId, conductor);
        return ResponseEntity.ok(new ApiResponse<>(
            "Conductor updated successfully",
            updated
        ));
    }

    /**
     * Delete a conductor.
     * DELETE /api/v1/conductors/{conductorId}
     *
     * @param conductorId The conductor ID
     * @return Success message
     */
    @DeleteMapping("/{conductorId}")
    public ResponseEntity<ApiResponse<Void>> deleteConductor(@PathVariable Long conductorId) {
        accountsService.deleteConductor(conductorId);
        return ResponseEntity.ok(new ApiResponse<>(
            "Conductor deleted successfully",
            null
        ));
    }
}
