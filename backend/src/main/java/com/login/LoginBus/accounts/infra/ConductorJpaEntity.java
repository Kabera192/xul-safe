package com.login.LoginBus.accounts.infra;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.login.LoginBus.accounts.domain.Conductor;
import com.login.LoginBus.accounts.domain.ConductorStatus;
import jakarta.persistence.*;
import java.time.LocalDate;

/**
 * JPA Entity for Conductor persistence.
 * Handles database mapping and conversion to/from domain entity.
 */
@Entity
@Table(name = "conductors")
public class ConductorJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, name = "full_name")
    @JsonProperty("fullName")
    private String fullName;

    @Column(nullable = false, name = "phone_number")
    @JsonProperty("phoneNumber")
    private String phoneNumber;

    @Column(name = "photo_url", columnDefinition = "TEXT")
    @JsonProperty("photoUrl")
    private String photoUrl;

    @Column
    private String email;

    @Column
    private String gender;

    @Column
    private Integer age;

    @Column(name = "driver_id")
    @JsonProperty("driverId")
    private String driverId;

    @Column(name = "licence_number")
    @JsonProperty("licenceNumber")
    private String licenceNumber;

    @Column(name = "licence_type")
    @JsonProperty("licenceType")
    private String licenceType;

    @Column(name = "licence_expiry")
    @JsonProperty("licenceExpiry")
    private LocalDate licenceExpiry;

    @Column
    private String experience;

    @Enumerated(EnumType.STRING)
    @Column
    private ConductorStatus status;

    @Column(name = "user_id")
    @JsonProperty("userId")
    private Long userId;

    @Column(name = "created_at")
    @JsonProperty("createdAt")
    private Long createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = System.currentTimeMillis();
    }

    // No-arg constructor (required for JPA)
    public ConductorJpaEntity() {
    }

    /**
     * Convert JPA entity to domain entity.
     *
     * @return Domain Conductor entity
     */
    public Conductor toDomain() {
        return new Conductor(
            this.id,
            this.fullName,
            this.phoneNumber,
            this.photoUrl,
            this.email,
            this.gender,
            this.age,
            this.driverId,
            this.licenceNumber,
            this.licenceType,
            this.licenceExpiry,
            this.experience,
            this.status,
            this.createdAt
        );
    }

    /**
     * Convert domain entity to JPA entity.
     *
     * @param conductor Domain Conductor entity
     * @return JPA Conductor entity
     */
    public static ConductorJpaEntity fromDomain(Conductor conductor) {
        ConductorJpaEntity entity = new ConductorJpaEntity();
        entity.setId(conductor.getId());
        entity.setFullName(conductor.getFullName());
        entity.setPhoneNumber(conductor.getPhoneNumber());
        entity.setPhotoUrl(conductor.getPhotoUrl());
        entity.setEmail(conductor.getEmail());
        entity.setGender(conductor.getGender());
        entity.setAge(conductor.getAge());
        entity.setDriverId(conductor.getDriverId());
        entity.setLicenceNumber(conductor.getLicenceNumber());
        entity.setLicenceType(conductor.getLicenceType());
        entity.setLicenceExpiry(conductor.getLicenceExpiry());
        entity.setExperience(conductor.getExperience());
        entity.setStatus(conductor.getStatus());
        entity.createdAt = conductor.getCreatedAt();
        return entity;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public String getDriverId() {
        return driverId;
    }

    public void setDriverId(String driverId) {
        this.driverId = driverId;
    }

    public String getLicenceNumber() {
        return licenceNumber;
    }

    public void setLicenceNumber(String licenceNumber) {
        this.licenceNumber = licenceNumber;
    }

    public String getLicenceType() {
        return licenceType;
    }

    public void setLicenceType(String licenceType) {
        this.licenceType = licenceType;
    }

    public LocalDate getLicenceExpiry() {
        return licenceExpiry;
    }

    public void setLicenceExpiry(LocalDate licenceExpiry) {
        this.licenceExpiry = licenceExpiry;
    }

    public String getExperience() {
        return experience;
    }

    public void setExperience(String experience) {
        this.experience = experience;
    }

    public ConductorStatus getStatus() {
        return status;
    }

    public void setStatus(ConductorStatus status) {
        this.status = status;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }
}
