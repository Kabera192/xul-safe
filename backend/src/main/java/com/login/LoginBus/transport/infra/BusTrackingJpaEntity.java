package com.login.LoginBus.transport.infra;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.login.LoginBus.transport.domain.BusTracking;
import com.login.LoginBus.transport.domain.BusTrackingStatus;
import com.login.LoginBus.transport.domain.TripType;
import com.login.LoginBus.accounts.infra.ConductorJpaEntity;
import jakarta.persistence.*;

/**
 * JPA Entity for BusTracking persistence.
 * Handles database mapping and conversion to/from domain entity.
 */
@Entity
@Table(name = "bus_tracking")
public class BusTrackingJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private BusTrackingStatus status;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, name = "trip_type")
    @JsonProperty("tripType")
    private TripType tripType;

    @Column(name = "conductor_id")
    private Long conductorId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "conductor_id", insertable = false, updatable = false)
    private ConductorJpaEntity conductor;

    @Column(name = "bus_id")
    private Long busId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "bus_id", insertable = false, updatable = false)
    private BusJpaEntity bus;

    @Column(name = "current_latitude")
    @JsonProperty("currentLatitude")
    private Double currentLatitude;

    @Column(name = "current_longitude")
    @JsonProperty("currentLongitude")
    private Double currentLongitude;

    @Column(name = "start_time")
    @JsonProperty("startTime")
    private String startTime;

    @Column(name = "estimated_arrival")
    @JsonProperty("estimatedArrival")
    private String estimatedArrival;

    @Column(name = "route_id")
    @JsonProperty("routeId")
    private Long routeId;

    @Column(name = "child_id")
    @JsonProperty("childId")
    private String childId;

    @Column(name = "created_at")
    @JsonProperty("createdAt")
    private Long createdAt;

    @Column(name = "updated_at")
    @JsonProperty("updatedAt")
    private Long updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = System.currentTimeMillis();
        updatedAt = System.currentTimeMillis();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = System.currentTimeMillis();
    }

    // No-arg constructor (required for JPA)
    public BusTrackingJpaEntity() {
    }

    /**
     * Convert JPA entity to domain entity.
     *
     * @return Domain BusTracking entity
     */
    public BusTracking toDomain() {
        BusTracking tracking = new BusTracking(
            this.id,
            this.status,
            this.tripType,
            this.conductorId,
            this.busId,
            this.currentLatitude,
            this.currentLongitude,
            this.startTime,
            this.estimatedArrival,
            this.routeId,
            this.childId,
            this.createdAt,
            this.updatedAt
        );

        // Populate related entities if loaded
        if (this.conductor != null) {
            tracking.setConductor(this.conductor.toDomain());
        }
        if (this.bus != null) {
            tracking.setBus(this.bus.toDomain());
        }

        return tracking;
    }

    /**
     * Convert domain entity to JPA entity.
     *
     * @param tracking Domain BusTracking entity
     * @return JPA BusTracking entity
     */
    public static BusTrackingJpaEntity fromDomain(BusTracking tracking) {
        BusTrackingJpaEntity entity = new BusTrackingJpaEntity();
        entity.setId(tracking.getId());
        entity.setStatus(tracking.getStatus());
        entity.setTripType(tracking.getTripType());
        entity.setConductorId(tracking.getConductorId());
        entity.setBusId(tracking.getBusId());
        entity.setCurrentLatitude(tracking.getCurrentLatitude());
        entity.setCurrentLongitude(tracking.getCurrentLongitude());
        entity.setStartTime(tracking.getStartTime());
        entity.setEstimatedArrival(tracking.getEstimatedArrival());
        entity.setRouteId(tracking.getRouteId());
        entity.setChildId(tracking.getChildId());
        entity.createdAt = tracking.getCreatedAt();
        entity.updatedAt = tracking.getUpdatedAt();
        return entity;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public BusTrackingStatus getStatus() {
        return status;
    }

    public void setStatus(BusTrackingStatus status) {
        this.status = status;
    }

    public TripType getTripType() {
        return tripType;
    }

    public void setTripType(TripType tripType) {
        this.tripType = tripType;
    }

    public Long getConductorId() {
        return conductorId;
    }

    public void setConductorId(Long conductorId) {
        this.conductorId = conductorId;
    }

    public ConductorJpaEntity getConductor() {
        return conductor;
    }

    public void setConductor(ConductorJpaEntity conductor) {
        this.conductor = conductor;
    }

    public Long getBusId() {
        return busId;
    }

    public void setBusId(Long busId) {
        this.busId = busId;
    }

    public BusJpaEntity getBus() {
        return bus;
    }

    public void setBus(BusJpaEntity bus) {
        this.bus = bus;
    }

    public Double getCurrentLatitude() {
        return currentLatitude;
    }

    public void setCurrentLatitude(Double currentLatitude) {
        this.currentLatitude = currentLatitude;
    }

    public Double getCurrentLongitude() {
        return currentLongitude;
    }

    public void setCurrentLongitude(Double currentLongitude) {
        this.currentLongitude = currentLongitude;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEstimatedArrival() {
        return estimatedArrival;
    }

    public void setEstimatedArrival(String estimatedArrival) {
        this.estimatedArrival = estimatedArrival;
    }

    public Long getRouteId() {
        return routeId;
    }

    public void setRouteId(Long routeId) {
        this.routeId = routeId;
    }

    public String getChildId() {
        return childId;
    }

    public void setChildId(String childId) {
        this.childId = childId;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public Long getUpdatedAt() {
        return updatedAt;
    }
}
