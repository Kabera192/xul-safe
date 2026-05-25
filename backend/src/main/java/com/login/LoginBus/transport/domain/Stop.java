package com.login.LoginBus.transport.domain;

public class Stop {
    private Long id;
    private Long routeId;
    private String name;
    private Double latitude;
    private Double longitude;
    private Integer orderIndex;
    private Long createdAt;

    public Stop() {}

    public Stop(Long id, Long routeId, String name, Double latitude, Double longitude,
                Integer orderIndex, Long createdAt) {
        this.id = id;
        this.routeId = routeId;
        this.name = name;
        this.latitude = latitude;
        this.longitude = longitude;
        this.orderIndex = orderIndex;
        this.createdAt = createdAt;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getRouteId() { return routeId; }
    public void setRouteId(Long routeId) { this.routeId = routeId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public Integer getOrderIndex() { return orderIndex; }
    public void setOrderIndex(Integer orderIndex) { this.orderIndex = orderIndex; }
    public Long getCreatedAt() { return createdAt; }
    public void setCreatedAt(Long createdAt) { this.createdAt = createdAt; }
}
