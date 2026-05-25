package com.login.LoginBus.transport.domain;

import com.login.LoginBus.accounts.domain.Conductor;

/**
 * Pure domain entity for BusTracking.
 * Contains NO framework annotations - only business logic.
 */
public class BusTracking {

    private String id;
    private BusTrackingStatus status;
    private TripType tripType;
    private Long conductorId;
    private Conductor conductor; // Populated when needed from accounts module
    private Long busId;
    private Bus bus; // Populated when needed
    private Double currentLatitude;
    private Double currentLongitude;
    private String startTime;
    private String estimatedArrival;
    private Long routeId;
    private String childId;
    private Long createdAt;
    private Long updatedAt;

    // No-arg constructor
    public BusTracking() {
    }

    // Full constructor
    public BusTracking(String id, BusTrackingStatus status, TripType tripType, Long conductorId,
                      Long busId, Double currentLatitude, Double currentLongitude,
                      String startTime, String estimatedArrival, Long routeId, String childId,
                      Long createdAt, Long updatedAt) {
        this.id = id;
        this.status = status;
        this.tripType = tripType;
        this.conductorId = conductorId;
        this.busId = busId;
        this.currentLatitude = currentLatitude;
        this.currentLongitude = currentLongitude;
        this.startTime = startTime;
        this.estimatedArrival = estimatedArrival;
        this.routeId = routeId;
        this.childId = childId;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Business logic methods
    public boolean isActive() {
        return status != null &&
               (status == BusTrackingStatus.PICKING_UP_CHILDREN ||
                status == BusTrackingStatus.GOING_TO_SCHOOL ||
                status == BusTrackingStatus.DROPPING_OFF_CHILDREN);
    }

    public String getStatusMessage() {
        if (status == null) {
            return "No tracking information";
        }

        switch (status) {
            case PICKING_UP_CHILDREN:
                return "Bus is picking up children";
            case GOING_TO_SCHOOL:
                return "Bus is going to school";
            case AT_SCHOOL:
                return "Bus is at school";
            case DROPPING_OFF_CHILDREN:
                return "Bus is dropping off children";
            case NOT_IN_ROUTE:
            default:
                return "Bus is not in route";
        }
    }

    public boolean hasLocation() {
        return currentLatitude != null && currentLongitude != null;
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

    public Conductor getConductor() {
        return conductor;
    }

    public void setConductor(Conductor conductor) {
        this.conductor = conductor;
    }

    public Long getBusId() {
        return busId;
    }

    public void setBusId(Long busId) {
        this.busId = busId;
    }

    public Bus getBus() {
        return bus;
    }

    public void setBus(Bus bus) {
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

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }

    public Long getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Long updatedAt) {
        this.updatedAt = updatedAt;
    }
}
