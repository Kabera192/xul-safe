package com.login.LoginBus.incidents.api;

import com.login.LoginBus.incidents.api.dto.CreateIncidentRequest;
import com.login.LoginBus.incidents.api.dto.IncidentResponse;
import com.login.LoginBus.incidents.api.dto.UpdateIncidentRequest;
import com.login.LoginBus.incidents.app.IncidentService;
import com.login.LoginBus.incidents.domain.Incident;
import com.login.LoginBus.shared.api.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for incident operations.
 */
@RestController
@RequestMapping("/api/v1/incidents")
@CrossOrigin(origins = "*")
public class IncidentController {

    private final IncidentService incidentService;

    public IncidentController(IncidentService incidentService) {
        this.incidentService = incidentService;
    }

    /**
     * Create a new incident.
     */
    @PostMapping
    public ResponseEntity<ApiResponse<IncidentResponse>> createIncident(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody CreateIncidentRequest request
    ) {
        Incident incident = incidentService.createIncident(jwt, request);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new ApiResponse<>(
                        "Incident created successfully",
                        IncidentResponse.fromDomain(incident)
                ));
    }

    /**
     * Get all incidents.
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<IncidentResponse>>> getAllIncidents() {
        List<IncidentResponse> incidents = incidentService.getAllIncidents()
                .stream()
                .map(IncidentResponse::fromDomain)
                .toList();

        return ResponseEntity.ok(
                new ApiResponse<>(
                        "Incidents retrieved successfully",
                        incidents
                )
        );
    }

    /**
     * Get one incident by ID.
     */
    @GetMapping("/{incidentId}")
    public ResponseEntity<ApiResponse<IncidentResponse>> getIncidentById(
            @PathVariable Long incidentId
    ) {
        Incident incident =
                incidentService.getIncidentById(incidentId);

        return ResponseEntity.ok(
                new ApiResponse<>(
                        "Incident retrieved successfully",
                        IncidentResponse.fromDomain(incident)
                )
        );
    }

    /**
     * Update editable information on an ACTIVE incident.
     */
    @PatchMapping("/{incidentId}")
    public ResponseEntity<ApiResponse<IncidentResponse>> updateIncident(
            @PathVariable Long incidentId,
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody UpdateIncidentRequest request
    ) {
        Incident incident =
                incidentService.updateIncident(
                        incidentId,
                        jwt,
                        request
                );

        return ResponseEntity.ok(
                new ApiResponse<>(
                        "Incident updated successfully",
                        IncidentResponse.fromDomain(incident)
                )
        );
    }

    /**
     * Resolve an ACTIVE incident.
     */
    @PatchMapping("/{incidentId}/resolve")
    public ResponseEntity<ApiResponse<IncidentResponse>> resolveIncident(
            @PathVariable Long incidentId,
            @AuthenticationPrincipal Jwt jwt
    ) {
        Incident incident =
                incidentService.resolveIncident(
                        incidentId,
                        jwt
                );

        return ResponseEntity.ok(
                new ApiResponse<>(
                        "Incident resolved successfully",
                        IncidentResponse.fromDomain(incident)
                )
        );
    }
}