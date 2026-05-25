package com.login.LoginBus.transport.domain;

/**
 * Pure domain entity for BusStop.
 * Contains NO framework annotations - only business logic.
 */
public class BusStop {

    private String id;
    private String name;
    private Double latitude;
    private Double longitude;
    private String address;
    private String description;
    private Long routeId;
    private Integer stopOrder;

    // No-arg constructor
    public BusStop() {
    }

    // Full constructor
    public BusStop(String id, String name, Double latitude, Double longitude,
                   String address, String description) {
        this.id = id;
        this.name = name;
        this.latitude = latitude;
        this.longitude = longitude;
        this.address = address;
        this.description = description;
    }

    // Full constructor with routeId
    public BusStop(String id, String name, Double latitude, Double longitude,
                   String address, String description, Long routeId, Integer stopOrder) {
        this.id = id;
        this.name = name;
        this.latitude = latitude;
        this.longitude = longitude;
        this.address = address;
        this.description = description;
        this.routeId = routeId;
        this.stopOrder = stopOrder;
    }

    // Business logic methods
    public boolean hasLocation() {
        return latitude != null && longitude != null;
    }

    public String getDisplayInfo() {
        return name + (address != null ? " - " + address : "");
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Long getRouteId() {
        return routeId;
    }

    public void setRouteId(Long routeId) {
        this.routeId = routeId;
    }

    public Integer getStopOrder() {
        return stopOrder;
    }

    public void setStopOrder(Integer stopOrder) {
        this.stopOrder = stopOrder;
    }
}
