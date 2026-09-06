package com.login.LoginBus.incidents.domain;

import java.util.HashSet;
import java.util.Set;

/**
 * Pure domain entity for Incident.
 * Contains NO framework annotations - only incident data and business logic.
 */
public class Incident {

    private Long id;
    private IncidentType type;
    private String description;
    private IncidentStatus status;
    private JourneyImpact journeyImpact;

    private Long createdBy;
    private Long createdAt;

    private Long resolvedBy;
    private Long resolvedAt;

    private Set<Long> affectedBusIds = new HashSet<>();
    private Set<String> affectedChildIds = new HashSet<>();
    private Set<String> relatedTrackingIds = new HashSet<>();

    public Incident() {
    }

    public Incident(
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
        this.affectedBusIds = affectedBusIds != null ? new HashSet<>(affectedBusIds) : new HashSet<>();
        this.affectedChildIds = affectedChildIds != null ? new HashSet<>(affectedChildIds) : new HashSet<>();
        this.relatedTrackingIds = relatedTrackingIds != null ? new HashSet<>(relatedTrackingIds) : new HashSet<>();
    }

    // Business logic methods

    public boolean isActive() {
        return status == IncidentStatus.ACTIVE;
    }

    public boolean isResolved() {
        return status == IncidentStatus.RESOLVED;
    }

    public void resolve(Long resolvedBy) {
        if (isResolved()) {
            throw new IllegalStateException("Incident is already resolved");
        }

        this.status = IncidentStatus.RESOLVED;
        this.resolvedBy = resolvedBy;
        this.resolvedAt = System.currentTimeMillis();
    }

    // Getters and Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public IncidentStatus getStatus() {
        return status;
    }

    public void setStatus(IncidentStatus status) {
        this.status = status;
    }

    public JourneyImpact getJourneyImpact() {
        return journeyImpact;
    }

    public void setJourneyImpact(JourneyImpact journeyImpact) {
        this.journeyImpact = journeyImpact;
    }

    public Long getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Long createdBy) {
        this.createdBy = createdBy;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }

    public Long getResolvedBy() {
        return resolvedBy;
    }

    public void setResolvedBy(Long resolvedBy) {
        this.resolvedBy = resolvedBy;
    }

    public Long getResolvedAt() {
        return resolvedAt;
    }

    public void setResolvedAt(Long resolvedAt) {
        this.resolvedAt = resolvedAt;
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

    public Set<String> getRelatedTrackingIds() {
        return relatedTrackingIds;
    }

    public void setRelatedTrackingIds(Set<String> relatedTrackingIds) {
        this.relatedTrackingIds = relatedTrackingIds != null
                ? new HashSet<>(relatedTrackingIds)
                : new HashSet<>();
    }
}