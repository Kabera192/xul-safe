package com.login.LoginBus.transport.infra;

import com.login.LoginBus.transport.domain.BusStop;
import jakarta.persistence.*;

/**
 * JPA Entity for BusStop persistence.
 * Handles database mapping and conversion to/from domain entity.
 */
@Entity
@Table(name = "bus_stops")
public class BusStopJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    @Column(nullable = false)
    private String address;

    @Column
    private String description;

    @Column(name = "route_id")
    private Long routeId;

    @Column(name = "stop_order")
    private Integer stopOrder;

    // No-arg constructor (required for JPA)
    public BusStopJpaEntity() {
    }

    /**
     * Convert JPA entity to domain entity.
     *
     * @return Domain BusStop entity
     */
    public BusStop toDomain() {
        return new BusStop(
            this.id,
            this.name,
            this.latitude,
            this.longitude,
            this.address,
            this.description,
            this.routeId,
            this.stopOrder
        );
    }

    /**
     * Convert domain entity to JPA entity.
     *
     * @param busStop Domain BusStop entity
     * @return JPA BusStop entity
     */
    public static BusStopJpaEntity fromDomain(BusStop busStop) {
        BusStopJpaEntity entity = new BusStopJpaEntity();
        entity.setId(busStop.getId());
        entity.setName(busStop.getName());
        entity.setLatitude(busStop.getLatitude());
        entity.setLongitude(busStop.getLongitude());
        entity.setAddress(busStop.getAddress());
        entity.setDescription(busStop.getDescription());
        entity.setRouteId(busStop.getRouteId());
        entity.setStopOrder(busStop.getStopOrder());
        return entity;
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
