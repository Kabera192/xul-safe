package com.login.LoginBus.transport.domain;

/**
 * Pure domain entity for Journey.
 * Contains NO framework annotations - only business logic.
 */
public class Journey {

    private Long id;
    private String childId;
    private String childName;
    private String routeName;
    private Long routeId;
    private JourneyType journeyType;
    private JourneyStatus status;
    private String date; // yyyy-MM-dd
    private String startTime; // HH:mm:ss
    private String endTime;
    private String startLocation;
    private String endLocation;
    private Long createdAt;

    // No-arg constructor
    public Journey() {
    }

    // Full constructor
    public Journey(Long id, String childId, String childName, String routeName, Long routeId,
                   JourneyType journeyType, JourneyStatus status, String date, String startTime,
                   String endTime, String startLocation, String endLocation, Long createdAt) {
        this.id = id;
        this.childId = childId;
        this.childName = childName;
        this.routeName = routeName;
        this.routeId = routeId;
        this.journeyType = journeyType;
        this.status = status;
        this.date = date;
        this.startTime = startTime;
        this.endTime = endTime;
        this.startLocation = startLocation;
        this.endLocation = endLocation;
        this.createdAt = createdAt;
    }

    // Business logic methods
    public boolean isInProgress() {
        return status == JourneyStatus.IN_PROGRESS;
    }

    public boolean isCompleted() {
        return status == JourneyStatus.COMPLETED;
    }

    public boolean isPickup() {
        return journeyType == JourneyType.PICKUP;
    }

    public boolean isDropoff() {
        return journeyType == JourneyType.DROPOFF;
    }

    public String getJourneyDescription() {
        return journeyType.name() + " - " + routeName;
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
