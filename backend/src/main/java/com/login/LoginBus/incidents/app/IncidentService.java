package com.login.LoginBus.incidents.app;

import com.login.LoginBus.incidents.api.dto.CreateIncidentRequest;
import com.login.LoginBus.incidents.api.dto.ParentIncidentResponse;
import com.login.LoginBus.incidents.api.dto.UpdateIncidentRequest;
import com.login.LoginBus.incidents.domain.Incident;
import org.springframework.security.oauth2.jwt.Jwt;

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
}