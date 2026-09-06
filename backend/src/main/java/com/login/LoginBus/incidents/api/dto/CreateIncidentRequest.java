package com.login.LoginBus.incidents.api.dto;

import com.login.LoginBus.incidents.domain.IncidentType;
import com.login.LoginBus.incidents.domain.JourneyImpact;

import java.util.HashSet;
import java.util.Set;

/**
 * Request used when creating an incident.
 *
 * Backend-controlled fields such as status, createdBy, createdAt,
 * resolvedBy, resolvedAt, and tracking IDs are intentionally absent.
 */
public class CreateIncidentRequest {

    private IncidentType type;
    private String description;
    private JourneyImpact journeyImpact;

    private Set<Long> affectedBusIds = new HashSet<>();
    private Set<String> affectedChildIds = new HashSet<>();

    public CreateIncidentRequest() {
    }

    public IncidentType getType() {
        return type;
    }

    public void setType(IncidentType type) {
        this.type = type;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public JourneyImpact getJourneyImpact() {
        return journeyImpact;
    }

    public void setJourneyImpact(JourneyImpact journeyImpact) {
        this.journeyImpact = journeyImpact;
    }

    public Set<Long> getAffectedBusIds() {
        return affectedBusIds;
    }

    public void setAffectedBusIds(Set<Long> affectedBusIds) {
        this.affectedBusIds = affectedBusIds != null
                ? new HashSet<>(affectedBusIds)
                : new HashSet<>();
    }

    public Set<String> getAffectedChildIds() {
        return affectedChildIds;
    }

    public void setAffectedChildIds(Set<String> affectedChildIds) {
        this.affectedChildIds = affectedChildIds != null
                ? new HashSet<>(affectedChildIds)
                : new HashSet<>();
    }
}