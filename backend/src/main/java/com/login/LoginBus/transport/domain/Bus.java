package com.login.LoginBus.transport.domain;

/**
 * Pure domain entity for Bus.
 * Contains NO framework annotations - only business logic.
 */
public class Bus {

    private Long id;
    private String plateNumber;
    private String model;
    private Integer capacity;
    private BusStatus status;
    private Long conductorId;
    private String deviceId;
    private Long routeId;
    private String photoUrl;
    private Long createdAt;

    // No-arg constructor
    public Bus() {
    }

    // Full constructor
    public Bus(Long id, String plateNumber, String model, Integer capacity, BusStatus status,
               Long conductorId, String deviceId, Long routeId, String photoUrl, Long createdAt) {
        this.id = id;
        this.plateNumber = plateNumber;
        this.model = model;
        this.capacity = capacity;
        this.status = status;
        this.conductorId = conductorId;
        this.deviceId = deviceId;
        this.routeId = routeId;
        this.photoUrl = photoUrl;
        this.createdAt = createdAt;
    }

    // Business logic methods
    public boolean isActive() {
        return status == BusStatus.ACTIVE;
    }

    public boolean canAcceptPassengers() {
        return isActive() && capacity != null && capacity > 0;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getPlateNumber() {
        return plateNumber;
    }

    public void setPlateNumber(String plateNumber) {
        this.plateNumber = plateNumber;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public Integer getCapacity() {
        return capacity;
    }

    public void setCapacity(Integer capacity) {
        this.capacity = capacity;
    }

    public BusStatus getStatus() {
        return status;
    }

    public void setStatus(BusStatus status) {
        this.status = status;
    }

    public Long getConductorId() {
        return conductorId;
    }

    public void setConductorId(Long conductorId) {
        this.conductorId = conductorId;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    public Long getRouteId() {
        return routeId;
    }

    public void setRouteId(Long routeId) {
        this.routeId = routeId;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }
}
