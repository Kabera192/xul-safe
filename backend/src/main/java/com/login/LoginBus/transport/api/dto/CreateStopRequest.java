package com.login.LoginBus.transport.api.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Request to create a bus stop.
 * Accepts both Flutter field names (locationName/locationLat/locationLong)
 * and standard names (name/latitude/longitude).
 */
public class CreateStopRequest {

    // Flutter sends 'locationName'; standard name is 'name'
    @JsonAlias("locationName")
    private String name;

    // Flutter sends 'locationLat'; standard name is 'latitude'
    @JsonAlias("locationLat")
    private Double latitude;

    // Flutter sends 'locationLong'; standard name is 'longitude'
    @JsonAlias("locationLong")
    private Double longitude;

    @JsonProperty("order_index")
    private Integer orderIndex;

    public CreateStopRequest() {}

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }
    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public Integer getOrderIndex() { return orderIndex; }
    public void setOrderIndex(Integer orderIndex) { this.orderIndex = orderIndex; }
}
