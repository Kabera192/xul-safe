package com.login.LoginBus.incidents.api;

import com.login.LoginBus.incidents.api.dto.CreateIncidentRequest;
import com.login.LoginBus.incidents.api.dto.IncidentResponse;
import com.login.LoginBus.incidents.api.dto.UpdateIncidentRequest;
import com.login.LoginBus.incidents.api.dto.ParentIncidentResponse;
import com.login.LoginBus.incidents.app.IncidentService;
import com.login.LoginBus.incidents.domain.Incident;
import com.login.LoginBus.incidents.domain.IncidentAttachment;
import com.login.LoginBus.incidents.domain.IncidentAttachmentType;
import com.login.LoginBus.incidents.infra.IncidentAttachmentStorage;
import com.login.LoginBus.incidents.api.dto.IncidentAttachmentResponse;
import com.login.LoginBus.shared.api.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * REST controller for incident operations.
 */
@RestController
@RequestMapping("/api/v1/incidents")
@CrossOrigin(origins = "*")
public class IncidentController {

private final IncidentService incidentService;
private final IncidentAttachmentStorage attachmentStorage;

public IncidentController(
        IncidentService incidentService,
        IncidentAttachmentStorage attachmentStorage
) {
    this.incidentService = incidentService;
    this.attachmentStorage = attachmentStorage;
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
 * Get incidents related to the authenticated transport user.
 */
@GetMapping("/me")
public ResponseEntity<ApiResponse<List<IncidentResponse>>> getMyIncidents(
        @AuthenticationPrincipal Jwt jwt
) {
    List<IncidentResponse> incidents = incidentService.getMyIncidents(jwt)
            .stream()
            .map(IncidentResponse::fromDomain)
            .toList();

    return ResponseEntity.ok(
            new ApiResponse<>(
                    "Transport-user incidents retrieved successfully",
                    incidents
            )
    );
}

/**
 * Get incidents visible to the authenticated parent.
 */
@GetMapping("/parent/me")
public ResponseEntity<ApiResponse<List<ParentIncidentResponse>>> getParentIncidents(
        @AuthenticationPrincipal Jwt jwt
) {
    List<ParentIncidentResponse> incidents =
            incidentService.getParentIncidents(jwt);

    return ResponseEntity.ok(
            new ApiResponse<>(
                    "Parent incidents retrieved successfully",
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

    /**
     * Upload an image or voice-note attachment to an ACTIVE incident.
     */
    @PostMapping(
            value = "/{incidentId}/attachments",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
public ResponseEntity<ApiResponse<IncidentAttachmentResponse>> addAttachment(
                    @PathVariable Long incidentId,
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam("file") MultipartFile file,
            @RequestParam("type") IncidentAttachmentType type
    ) {
        IncidentAttachment attachment =
                incidentService.addAttachment(
                        incidentId,
                        jwt,
                        file,
                        type
                );

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new ApiResponse<>(
        "Incident attachment uploaded successfully",
        IncidentAttachmentResponse.fromDomain(attachment)
));
    }

    /**
     * Get attachment metadata for an incident.
     */
    @GetMapping("/{incidentId}/attachments")
    public ResponseEntity<ApiResponse<List<IncidentAttachmentResponse>>> getAttachments(
            @PathVariable Long incidentId,
            @AuthenticationPrincipal Jwt jwt
    ) {
        List<IncidentAttachmentResponse> attachments =
        incidentService.getAttachments(
                        incidentId,
                        jwt
                )
                .stream()
                .map(IncidentAttachmentResponse::fromDomain)
                .toList();

        return ResponseEntity.ok(
                new ApiResponse<>(
                        "Incident attachments retrieved successfully",
                        attachments
                )
        );
    }

    /**
     * Download/view one incident attachment.
     */
    @GetMapping("/{incidentId}/attachments/{attachmentId}")
    public ResponseEntity<byte[]> getAttachment(
            @PathVariable Long incidentId,
            @PathVariable Long attachmentId,
            @AuthenticationPrincipal Jwt jwt
    ) {
        /*
         * Calling the service first is important because it verifies both
         * that the attachment belongs to this incident and that the
         * authenticated user is allowed to see it.
         */
        IncidentAttachment attachment =
                incidentService.getAttachment(
                        incidentId,
                        attachmentId,
                        jwt
                );

        byte[] data =
                attachmentStorage.read(
                        attachment.getStoragePath()
                );

        MediaType mediaType =
                attachment.getType() == IncidentAttachmentType.IMAGE
                        ? MediaType.IMAGE_JPEG
                        : MediaType.parseMediaType("audio/mp4");

        return ResponseEntity.ok()
                .header(
                        HttpHeaders.CONTENT_DISPOSITION,
                        "inline"
                )
                .contentType(mediaType)
                .contentLength(data.length)
                .body(data);
    }    

}