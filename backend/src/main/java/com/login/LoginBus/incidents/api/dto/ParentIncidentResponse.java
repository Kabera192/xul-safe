package com.login.LoginBus.incidents.api.dto;

import com.login.LoginBus.incidents.domain.IncidentStatus;
import com.login.LoginBus.incidents.domain.IncidentType;
import com.login.LoginBus.incidents.domain.JourneyImpact;

import java.util.HashSet;
import java.util.Set;

/**
 * Parent-safe API response for an incident.
 *
 * This response intentionally excludes internal fields such as:
 * - createdBy
 * - resolvedBy
 * - affectedBusIds
 * - relatedTrackingIds
 *
 * affectedChildIds must contain only children belonging to the
 * authenticated parent.
 */
public class ParentIncidentResponse {

    private Long id;
    private IncidentType type;
    private String description;
    private IncidentStatus status;
    private JourneyImpact journeyImpact;

    private Long createdAt;
    private Long resolvedAt;

    private Set<String> affectedChildIds = new HashSet<>();

    public ParentIncidentResponse() {
    }

    public ParentIncidentResponse(
            Long id,
            IncidentType type,
            String description,
            IncidentStatus status,
            JourneyImpact journeyImpact,
            Long createdAt,
            Long resolvedAt,
            Set<String> affectedChildIds
    ) {
        this.id = id;
        this.type = type;
        this.description = description;
        this.status = status;
        this.journeyImpact = journeyImpact;
        this.createdAt = createdAt;
        this.resolvedAt = resolvedAt;
        this.affectedChildIds = affectedChildIds != null
                ? new HashSet<>(affectedChildIds)
                : new HashSet<>();
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

    public Long getCreatedAt() {
        return createdAt;
    }

    public Long getResolvedAt() {
        return resolvedAt;
    }

    public Set<String> getAffectedChildIds() {
        return affectedChildIds;
    }
}