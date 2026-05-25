package com.login.LoginBus.transport.infra;

import com.login.LoginBus.transport.domain.Journey;
import com.login.LoginBus.transport.domain.JourneyType;
import com.login.LoginBus.transport.domain.JourneyStatus;
import jakarta.persistence.*;

/**
 * JPA Entity for Journey persistence.
 * Handles database mapping and conversion to/from domain entity.
 */
@Entity
@Table(name = "journeys")
public class JourneyJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "child_id", nullable = false)
    private String childId;

    @Column(name = "child_name", nullable = false)
    private String childName;

    @Column(name = "route_name", nullable = false)
    private String routeName;

    @Column(name = "route_id", nullable = false)
    private Long routeId;

    @Enumerated(EnumType.STRING)
    @Column(name = "journey_type", nullable = false)
    private JourneyType journeyType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private JourneyStatus status;

    @Column(nullable = false)
    private String date; // yyyy-MM-dd

    @Column(name = "start_time", nullable = false)
    private String startTime; // HH:mm:ss

    @Column(name = "end_time")
    private String endTime;

    @Column(name = "start_location")
    private String startLocation;

    @Column(name = "end_location")
    private String endLocation;

    @Column(name = "created_at")
    private Long createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = System.currentTimeMillis();
    }

    // No-arg constructor (required for JPA)
    public JourneyJpaEntity() {
    }

    /**
     * Convert JPA entity to domain entity.
     *
     * @return Domain Journey entity
     */
    public Journey toDomain() {
        return new Journey(
            this.id,
            this.childId,
            this.childName,
            this.routeName,
            this.routeId,
            this.journeyType,
            this.status,
            this.date,
            this.startTime,
            this.endTime,
            this.startLocation,
            this.endLocation,
            this.createdAt
        );
    }

    /**
     * Convert domain entity to JPA entity.
     *
     * @param journey Domain Journey entity
     * @return JPA Journey entity
     */
    public static JourneyJpaEntity fromDomain(Journey journey) {
        JourneyJpaEntity entity = new JourneyJpaEntity();
        entity.setId(journey.getId());
        entity.setChildId(journey.getChildId());
        entity.setChildName(journey.getChildName());
        entity.setRouteName(journey.getRouteName());
        entity.setRouteId(journey.getRouteId());
        entity.setJourneyType(journey.getJourneyType());
        entity.setStatus(journey.getStatus());
        entity.setDate(journey.getDate());
        entity.setStartTime(journey.getStartTime());
        entity.setEndTime(journey.getEndTime());
        entity.setStartLocation(journey.getStartLocation());
        entity.setEndLocation(journey.getEndLocation());
        entity.createdAt = journey.getCreatedAt();
        return entity;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getChildId() {
        return childId;
    }

    public void setChildId(String childId) {
        this.childId = childId;
    }

    public String getChildName() {
        return childName;
    }

    public void setChildName(String childName) {
        this.childName = childName;
    }

    public String getRouteName() {
        return routeName;
    }

    public void setRouteName(String routeName) {
        this.routeName = routeName;
    }

    public Long getRouteId() {
        return routeId;
    }

    public void setRouteId(Long routeId) {
        this.routeId = routeId;
    }

    public JourneyType getJourneyType() {
        return journeyType;
    }

    public void setJourneyType(JourneyType journeyType) {
        this.journeyType = journeyType;
    }

    public JourneyStatus getStatus() {
        return status;
    }

    public void setStatus(JourneyStatus status) {
        this.status = status;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public String getStartLocation() {
        return startLocation;
    }

    public void setStartLocation(String startLocation) {
        this.startLocation = startLocation;
    }

    public String getEndLocation() {
        return endLocation;
    }

    public void setEndLocation(String endLocation) {
        this.endLocation = endLocation;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }
}
