package com.login.LoginBus.transport.infra;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.login.LoginBus.transport.domain.Bus;
import com.login.LoginBus.transport.domain.BusStatus;
import jakarta.persistence.*;

/**
 * JPA Entity for Bus persistence.
 * Handles database mapping and conversion to/from domain entity.
 */
@Entity
@Table(name = "buses")
public class BusJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, name = "plate_number")
    @JsonProperty("plateNumber")
    private String plateNumber;

    @Column
    private String model;

    @Column
    private Integer capacity;

    @Enumerated(EnumType.STRING)
    @Column
    private BusStatus status;

    @Column(name = "conductor_id")
    @JsonProperty("conductorId")
    private Long conductorId;

    @Column(name = "device_id")
    @JsonProperty("deviceId")
    private String deviceId;

    @Column(name = "route_id")
    @JsonProperty("routeId")
    private Long routeId;

    @Column(name = "driver_id")
    @JsonProperty("driverId")
    private Long driverId;

    @Column(name = "photo_url", columnDefinition = "TEXT")
    @JsonProperty("photoUrl")
    private String photoUrl;

    @Column(name = "created_at")
    @JsonProperty("createdAt")
    private Long createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = System.currentTimeMillis();
    }

    // No-arg constructor (required for JPA)
    public BusJpaEntity() {
    }

    /**
     * Convert JPA entity to domain entity.
     *
     * @return Domain Bus entity
     */
    public Bus toDomain() {
        return new Bus(
            this.id,
            this.plateNumber,
            this.model,
            this.capacity,
            this.status,
            this.conductorId,
            this.deviceId,
            this.routeId,
            this.photoUrl,
            this.createdAt
        );
    }

    /**
     * Convert domain entity to JPA entity.
     *
     * @param bus Domain Bus entity
     * @return JPA Bus entity
     */
    public static BusJpaEntity fromDomain(Bus bus) {
        BusJpaEntity entity = new BusJpaEntity();
        entity.setId(bus.getId());
        entity.setPlateNumber(bus.getPlateNumber());
        entity.setModel(bus.getModel());
        entity.setCapacity(bus.getCapacity());
        entity.setStatus(bus.getStatus());
        entity.setConductorId(bus.getConductorId());
        entity.setDeviceId(bus.getDeviceId());
        entity.setRouteId(bus.getRouteId());
        entity.setPhotoUrl(bus.getPhotoUrl());
        entity.createdAt = bus.getCreatedAt();
        return entity;
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

    public Long getDriverId() {
        return driverId;
    }

    public void setDriverId(Long driverId) {
        this.driverId = driverId;
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
}
