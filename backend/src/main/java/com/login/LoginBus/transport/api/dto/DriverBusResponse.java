package com.login.LoginBus.transport.api.dto;

/**
 * Response for the driver's bus.
 * Field names match Flutter BusModel.fromApiResponse expectations:
 *   id, plateNumber, model, capacity, status, routeId, photoUrl
 */
public class DriverBusResponse {

    // Flutter reads 'id'
    private Long id;

    // Flutter reads 'plateNumber'
    private String plateNumber;

    private String model;

    private Integer capacity;

    private String status;

    // Flutter reads 'routeId'
    private Long routeId;

    // Flutter reads 'photoUrl'
    private String photoUrl;

    public DriverBusResponse() {}

    public DriverBusResponse(Long id, String plateNumber, String model, Integer capacity,
                              String status, Long routeId, String photoUrl) {
        this.id = id;
        this.plateNumber = plateNumber;
        this.model = model;
        this.capacity = capacity;
        this.status = status;
        this.routeId = routeId;
        this.photoUrl = photoUrl;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getPlateNumber() { return plateNumber; }
    public void setPlateNumber(String plateNumber) { this.plateNumber = plateNumber; }
    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }
    public Integer getCapacity() { return capacity; }
    public void setCapacity(Integer capacity) { this.capacity = capacity; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Long getRouteId() { return routeId; }
    public void setRouteId(Long routeId) { this.routeId = routeId; }
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
}
