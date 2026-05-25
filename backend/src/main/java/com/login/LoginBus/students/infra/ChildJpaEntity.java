package com.login.LoginBus.students.infra;

import com.login.LoginBus.students.domain.Child;
import com.login.LoginBus.students.domain.Gender;
import jakarta.persistence.*;

/**
 * JPA Entity for Child persistence.
 * Handles database mapping and conversion to/from domain entity.
 */
@Entity
@Table(name = "children")
public class ChildJpaEntity {

    @Id
    private String id;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @Column(name = "birth_date", nullable = false)
    private String birthDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Gender gender;

    @Column(nullable = false)
    private String grade;

    @Column(name = "photo_url", columnDefinition = "TEXT")
    private String photoUrl;

    @Column(name = "parent_id")
    private Long parentId;

    @Column(name = "bus_id")
    private Long busId;

    @Column(name = "route_id")
    private Long routeId;

    @Column(name = "bus_stop_id")
    private String busStopId;

    @Column(name = "pickup_stop_id")
    private Long pickupStopId;

    @Column(name = "dropoff_stop_id")
    private Long dropoffStopId;

    @Column(name = "created_at")
    private Long createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = System.currentTimeMillis();
        }
    }

    // No-arg constructor (required for JPA)
    public ChildJpaEntity() {
    }

    /**
     * Convert JPA entity to domain entity.
     *
     * @return Domain Child entity
     */
    public Child toDomain() {
        return new Child(
            this.id,
            this.fullName,
            this.birthDate,
            this.gender,
            this.grade,
            this.photoUrl,
            this.parentId,
            this.busId,
            this.routeId,
            this.busStopId,
            this.createdAt
        );
    }

    /**
     * Convert domain entity to JPA entity.
     *
     * @param child Domain Child entity
     * @return JPA Child entity
     */
    public static ChildJpaEntity fromDomain(Child child) {
        ChildJpaEntity entity = new ChildJpaEntity();
        entity.setId(child.getId());
        entity.setFullName(child.getFullName());
        entity.setBirthDate(child.getBirthDate());
        entity.setGender(child.getGender());
        entity.setGrade(child.getGrade());
        entity.setPhotoUrl(child.getPhotoUrl());
        entity.setParentId(child.getParentId());
        entity.setBusId(child.getBusId());
        entity.setRouteId(child.getRouteId());
        entity.setBusStopId(child.getBusStopId());
        entity.createdAt = child.getCreatedAt();
        return entity;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(String birthDate) {
        this.birthDate = birthDate;
    }

    public Gender getGender() {
        return gender;
    }

    public void setGender(Gender gender) {
        this.gender = gender;
    }

    public String getGrade() {
        return grade;
    }

    public void setGrade(String grade) {
        this.grade = grade;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public Long getParentId() {
        return parentId;
    }

    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }

    public Long getBusId() {
        return busId;
    }

    public void setBusId(Long busId) {
        this.busId = busId;
    }

    public Long getRouteId() {
        return routeId;
    }

    public void setRouteId(Long routeId) {
        this.routeId = routeId;
    }

    public String getBusStopId() {
        return busStopId;
    }

    public void setBusStopId(String busStopId) {
        this.busStopId = busStopId;
    }

    public Long getPickupStopId() {
        return pickupStopId;
    }

    public void setPickupStopId(Long pickupStopId) {
        this.pickupStopId = pickupStopId;
    }

    public Long getDropoffStopId() {
        return dropoffStopId;
    }

    public void setDropoffStopId(Long dropoffStopId) {
        this.dropoffStopId = dropoffStopId;
    }

    public Long getCreatedAt() {
        return createdAt;
    }
}
