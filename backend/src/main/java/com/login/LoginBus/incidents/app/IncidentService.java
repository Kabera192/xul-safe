package com.login.LoginBus.incidents.app;

import com.login.LoginBus.incidents.api.dto.CreateIncidentRequest;
import com.login.LoginBus.incidents.api.dto.ParentIncidentResponse;
import com.login.LoginBus.incidents.api.dto.UpdateIncidentRequest;
import com.login.LoginBus.incidents.domain.Incident;
import com.login.LoginBus.incidents.domain.IncidentAttachment;
import com.login.LoginBus.incidents.domain.IncidentAttachmentType;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * Service interface for incident operations.
 */
public interface IncidentService {

    Incident createIncident(Jwt jwt, CreateIncidentRequest request);

    Incident getIncidentById(Long incidentId);

    List<Incident> getAllIncidents();

    /**
     * Get incidents related to the authenticated transport user.
     *
     * An incident is related when the authenticated DRIVER/CONDUCTOR:
     * - created the incident, or
     * - has an assigned bus listed in affectedBusIds, or
     * - has a child assigned to their bus listed in affectedChildIds.
     *
     * Both ACTIVE and RESOLVED incidents are returned.
     */
    List<Incident> getMyIncidents(Jwt jwt);

    /**
         * Get incidents visible to the authenticated parent.
         *
         * Visibility rules:
         *
         * - If one of the parent's children is explicitly affected,
         *   return the full incident description and only that parent's
         *   affected child IDs.
         *
         * - If the incident is a general bus-level incident
         *   (no explicitly affected children) and affects a bus used by
         *   one of the parent's children, return the full incident.
         *
         * - If other children are explicitly affected but the incident
         *   DELAYS or STOPS a bus used by one of the parent's children,
         *   return a sanitized operational version.
         *
         * - Child-specific incidents with no journey impact are hidden
         *   from unrelated parents.
         *
         * Both ACTIVE and RESOLVED incidents are returned.
         */
        List<ParentIncidentResponse> getParentIncidents(Jwt jwt);

    Incident updateIncident(
            Long incidentId,
            Jwt jwt,
            UpdateIncidentRequest request
    );

    Incident resolveIncident(
            Long incidentId,
            Jwt jwt
    );

    /**

     * Store media evidence for an incident.

     *

     * The current mobile UI uses this for one image and one recorded

     * voice note, while the backend model supports multiple attachments.

     */

    IncidentAttachment addAttachment(

            Long incidentId,

            Jwt jwt,

            MultipartFile file,

            IncidentAttachmentType type

    );

    /**

     * Get attachment metadata after verifying that the authenticated

     * user is allowed to access the full incident evidence.

     */

    List<IncidentAttachment> getAttachments(

            Long incidentId,

            Jwt jwt

    );

    /**

     * Get one attachment after verifying both incident visibility and

     * attachment ownership.

     */

    IncidentAttachment getAttachment(

            Long incidentId,

            Long attachmentId,

            Jwt jwt

    );
}