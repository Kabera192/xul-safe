package com.login.LoginBus.incidents.api.dto;

import com.login.LoginBus.incidents.domain.Incident;
import com.login.LoginBus.incidents.domain.IncidentStatus;
import com.login.LoginBus.incidents.domain.IncidentType;
import com.login.LoginBus.incidents.domain.JourneyImpact;

import java.util.Set;

/**
 * API response for an incident.
 */
public class IncidentResponse {

    private Long id;
    private IncidentType type;
    private String description;
    private IncidentStatus status;
    private JourneyImpact journeyImpact;

    private Long createdBy;
    private Long createdAt;

    private Long resolvedBy;
    private Long resolvedAt;

    private Set<Long> affectedBusIds;
    private Set<String> affectedChildIds;
    private Set<String> relatedTrackingIds;

    public IncidentResponse() {
    }

    public IncidentResponse(
            Long id,
            IncidentType type,
            String description,
            IncidentStatus status,
            JourneyImpact journeyImpact,
            Long createdBy,
            Long createdAt,
            Long resolvedBy,
            Long resolvedAt,
            Set<Long> affectedBusIds,
            Set<String> affectedChildIds,
            Set<String> relatedTrackingIds
    ) {
        this.id = id;
        this.type = type;
        this.description = description;
        this.status = status;
        this.journeyImpact = journeyImpact;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
        this.resolvedBy = resolvedBy;
        this.resolvedAt = resolvedAt;
        this.affectedBusIds = affectedBusIds;
        this.affectedChildIds = affectedChildIds;
        this.relatedTrackingIds = relatedTrackingIds;
    }

    public static IncidentResponse fromDomain(Incident incident) {
        return new IncidentResponse(
                incident.getId(),
                incident.getType(),
                incident.getDescription(),
                incident.getStatus(),
                incident.getJourneyImpact(),
                incident.getCreatedBy(),
                incident.getCreatedAt(),
                incident.getResolvedBy(),
                incident.getResolvedAt(),
                incident.getAffectedBusIds(),
                incident.getAffectedChildIds(),
                incident.getRelatedTrackingIds()
        );
    }

    public Long getId() {
        return id;
    }

    public IncidentType getType() {
        return type;
    }

    public String getDescription() {
        return description;
    }

    public IncidentStatus getStatus() {
        return status;
    }

    public JourneyImpact getJourneyImpact() {
        return journeyImpact;
    }

    public Long getCreatedBy() {
        return createdBy;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public Long getResolvedBy() {
        return resolvedBy;
    }

    public Long getResolvedAt() {
        return resolvedAt;
    }

    public Set<Long> getAffectedBusIds() {
        return affectedBusIds;
    }

    public Set<String> getAffectedChildIds() {
        return affectedChildIds;
    }

    public Set<String> getRelatedTrackingIds() {
        return relatedTrackingIds;
    }
}