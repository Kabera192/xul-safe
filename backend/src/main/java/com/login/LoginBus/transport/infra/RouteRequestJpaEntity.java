package com.login.LoginBus.transport.infra;

import com.login.LoginBus.transport.domain.RouteRequest;
import com.login.LoginBus.transport.domain.RouteRequestStatus;
import jakarta.persistence.*;


/**
 * JPA entity for storing route requests.
 */
@Entity
@Table(name = "route_requests")
public class RouteRequestJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "parent_id", nullable = false)
    private Long parentId;

    @Column(name = "child_id", nullable = false)
    private String childId;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    @Column
    private String address;

    @Column
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RouteRequestStatus status;

    @Column(name = "created_at")
    private Long createdAt;

    @Column(name = "updated_at")
    private Long updatedAt;

    @PrePersist
    protected void onCreate() {
        long now = System.currentTimeMillis();
        if (createdAt == null) {
            createdAt = now;
        }
        if (updatedAt == null) {
            updatedAt = now;
        }
        if (status == null) {
            status = RouteRequestStatus.PENDING;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = System.currentTimeMillis();
    }

    public RouteRequestJpaEntity() {
    }

    public RouteRequest toDomain() {
        return new RouteRequest(
            this.id,
            this.parentId,
            this.childId,
            this.latitude,
            this.longitude,
            this.address,
            this.description,
            this.status,
            this.createdAt,
            this.updatedAt
        );
    }

    public static RouteRequestJpaEntity fromDomain(RouteRequest request) {
        RouteRequestJpaEntity entity = new RouteRequestJpaEntity();
        entity.setId(request.getId());
        entity.setParentId(request.getParentId());
        entity.setChildId(request.getChildId());
        entity.setLatitude(request.getLatitude());
        entity.setLongitude(request.getLongitude());
        entity.setAddress(request.getAddress());
        entity.setDescription(request.getDescription());
        entity.setStatus(request.getStatus());
        entity.setCreatedAt(request.getCreatedAt());
        entity.setUpdatedAt(request.getUpdatedAt());
        return entity;
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
