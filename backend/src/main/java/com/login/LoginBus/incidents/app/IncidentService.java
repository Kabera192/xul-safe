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

    Incident updateIncident(Long incidentId, Jwt jwt, UpdateIncidentRequest request);

    Incident resolveIncident(Long incidentId, Jwt jwt);
}