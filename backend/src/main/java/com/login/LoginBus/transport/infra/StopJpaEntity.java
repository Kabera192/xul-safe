package com.login.LoginBus.transport.infra;

import com.login.LoginBus.transport.domain.Stop;
import jakarta.persistence.*;

@Entity
@Table(name = "stops")
public class StopJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "route_id")
    private Long routeId;

    @Column(nullable = false)
    private String name;

    private Double latitude;

    private Double longitude;

    @Column(name = "order_index")
    private Integer orderIndex;

    @Column(name = "created_at")
    private Long createdAt;

    @Column(nullable = false)
    private Boolean active = true;

    @PrePersist
    protected void onCreate() {
        createdAt = System.currentTimeMillis();
        if (active == null) active = true;
    }

    public StopJpaEntity() {}

    public Stop toDomain() {
        return new Stop(id, routeId, name, latitude, longitude, orderIndex, createdAt);
    }

    public static StopJpaEntity fromDomain(Stop stop) {
        StopJpaEntity e = new StopJpaEntity();
        e.setId(stop.getId());
        e.setRouteId(stop.getRouteId());
        e.setName(stop.getName());
        e.setLatitude(stop.getLatitude());
        e.setLongitude(stop.getLongitude());
        e.setOrderIndex(stop.getOrderIndex());
        e.setCreatedAt(stop.getCreatedAt());
        return e;
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
    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }
}
