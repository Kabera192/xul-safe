package com.login.LoginBus.transport.domain;

/**
 * Domain entity for route requests (custom bus stop requests).
 */
public class RouteRequest {

    private Long id;
    private Long parentId;
    private String childId;
    private Double latitude;
    private Double longitude;
    private String address;
    private String description;
    private RouteRequestStatus status;
    private Long createdAt;
    private Long updatedAt;

    public RouteRequest() {
    }

    public RouteRequest(Long id, Long parentId, String childId, Double latitude, Double longitude,
                        String address, String description, RouteRequestStatus status,
                        Long createdAt, Long updatedAt) {
        this.id = id;
        this.parentId = parentId;
        this.childId = childId;
        this.latitude = latitude;
        this.longitude = longitude;
        this.address = address;
        this.description = description;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getParentId() {
        return parentId;
    }

    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }

    public String getChildId() {
        return childId;
    }

    public void setChildId(String childId) {
        this.childId = childId;
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

    public RouteRequestStatus getStatus() {
        return status;
    }

    public void setStatus(RouteRequestStatus status) {
        this.status = status;
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
