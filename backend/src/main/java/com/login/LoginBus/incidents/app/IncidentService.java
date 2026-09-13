package com.login.LoginBus.incidents.app;

import com.login.LoginBus.incidents.api.dto.CreateIncidentRequest;
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