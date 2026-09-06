package com.login.LoginBus.incidents.infra;

import com.login.LoginBus.incidents.domain.Incident;
import com.login.LoginBus.incidents.domain.IncidentStatus;
import com.login.LoginBus.incidents.domain.IncidentType;
import com.login.LoginBus.incidents.domain.JourneyImpact;
import jakarta.persistence.*;

import java.util.HashSet;
import java.util.Set;

/**
 * JPA entity for Incident persistence.
 * Stores incident data plus ID references to affected buses, children,
 * and related live tracking sessions.
 */
@Entity
@Table(name = "incidents")
public class IncidentJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private IncidentType type;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private IncidentStatus status;

    @Enumerated(EnumType.STRING)
    @Column(name = "journey_impact", nullable = false)
    private JourneyImpact journeyImpact;

    @Column(name = "created_by", nullable = false)
    private Long createdBy;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;

    @Column(name = "resolved_by")
    private Long resolvedBy;

    @Column(name = "resolved_at")
    private Long resolvedAt;

    @ElementCollection
    @CollectionTable(
            name = "incident_buses",
            joinColumns = @JoinColumn(name = "incident_id")
    )
    @Column(name = "bus_id", nullable = false)
    private Set<Long> affectedBusIds = new HashSet<>();

    @ElementCollection
    @CollectionTable(
            name = "incident_children",
            joinColumns = @JoinColumn(name = "incident_id")
    )
    @Column(name = "child_id", nullable = false)
    private Set<String> affectedChildIds = new HashSet<>();

    @ElementCollection
    @CollectionTable(
            name = "incident_trackings",
            joinColumns = @JoinColumn(name = "incident_id")
    )
    @Column(name = "tracking_id", nullable = false)
    private Set<String> relatedTrackingIds = new HashSet<>();

    public IncidentJpaEntity() {
    }

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = System.currentTimeMillis();
        }

        if (status == null) {
            status = IncidentStatus.ACTIVE;
        }
    }

    public Incident toDomain() {
        return new Incident(
                this.id,
                this.type,
                this.description,
                this.status,
                this.journeyImpact,
                this.createdBy,
                this.createdAt,
                this.resolvedBy,
                this.resolvedAt,
                this.affectedBusIds,
                this.affectedChildIds,
                this.relatedTrackingIds
        );
    }

    public static IncidentJpaEntity fromDomain(Incident incident) {
        IncidentJpaEntity entity = new IncidentJpaEntity();

        entity.setId(incident.getId());
        entity.setType(incident.getType());
        entity.setDescription(incident.getDescription());
        entity.setStatus(incident.getStatus());
        entity.setJourneyImpact(incident.getJourneyImpact());
        entity.setCreatedBy(incident.getCreatedBy());
        entity.setCreatedAt(incident.getCreatedAt());
        entity.setResolvedBy(incident.getResolvedBy());
        entity.setResolvedAt(incident.getResolvedAt());
        entity.setAffectedBusIds(incident.getAffectedBusIds());
        entity.setAffectedChildIds(incident.getAffectedChildIds());
        entity.setRelatedTrackingIds(incident.getRelatedTrackingIds());

        return entity;
    }

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