package com.login.LoginBus.transport.api.dto;

public class StopResponse {

    // Field names match Flutter StopModel.fromApiResponse expectations
    private Long id;          // Flutter reads 'id'
    private Long routeId;     // Flutter reads 'routeId'
    private String locationName;  // Flutter reads 'locationName'
    private Double locationLat;   // Flutter reads 'locationLat'
    private Double locationLong;  // Flutter reads 'locationLong'
    private Integer orderIndex;

    public StopResponse() {}

    public StopResponse(Long id, Long routeId, String locationName, Double locationLat,
                        Double locationLong, Integer orderIndex) {
        this.id = id;
        this.routeId = routeId;
        this.locationName = locationName;
        this.locationLat = locationLat;
        this.locationLong = locationLong;
        this.orderIndex = orderIndex;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getRouteId() { return routeId; }
    public void setRouteId(Long routeId) { this.routeId = routeId; }
    public String getLocationName() { return locationName; }
    public void setLocationName(String locationName) { this.locationName = locationName; }
    public Double getLocationLat() { return locationLat; }
    public void setLocationLat(Double locationLat) { this.locationLat = locationLat; }
    public Double getLocationLong() { return locationLong; }
    public void setLocationLong(Double locationLong) { this.locationLong = locationLong; }
    public Integer getOrderIndex() { return orderIndex; }
    public void setOrderIndex(Integer orderIndex) { this.orderIndex = orderIndex; }
}
