package com.login.LoginBus.incidents.api.dto;

import com.login.LoginBus.incidents.domain.JourneyImpact;

import java.util.Set;

/**
 * Request used to update an ACTIVE incident.
 *
 * Incident type, lifecycle status, creator/resolver information,
 * timestamps, and captured tracking IDs cannot be changed here.
 *
 * Null collections mean "leave unchanged".
 * Empty collections mean "clear the affected buses/children".
 */
public class UpdateIncidentRequest {

    private String description;
    private JourneyImpact journeyImpact;
    private Set<Long> affectedBusIds;
    private Set<String> affectedChildIds;

    public UpdateIncidentRequest() {
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
        this.affectedBusIds = affectedBusIds;
    }

    public Set<String> getAffectedChildIds() {
        return affectedChildIds;
    }

    public void setAffectedChildIds(Set<String> affectedChildIds) {
        this.affectedChildIds = affectedChildIds;
    }
}