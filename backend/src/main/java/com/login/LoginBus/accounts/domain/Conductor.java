package com.login.LoginBus.accounts.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDate;

/**
 * Pure domain entity for Conductor.
 * Contains NO framework annotations - only business logic.
 */
public class Conductor {

    private Long id;
    private String fullName;
    private String phoneNumber;
    private String photoUrl;
    private String email;
    private String gender;
    private Integer age;
    private String driverId;
    private String licenceNumber;
    private String licenceType;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate licenceExpiry;
    private String experience;
    private ConductorStatus status;
    private Long createdAt;

    // No-arg constructor
    public Conductor() {
    }

    // Full constructor
    public Conductor(Long id, String fullName, String phoneNumber, String photoUrl,
                     String email, String gender, Integer age, String driverId,
                     String licenceNumber, String licenceType, LocalDate licenceExpiry,
                     String experience, ConductorStatus status, Long createdAt) {
        this.id = id;
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.photoUrl = photoUrl;
        this.email = email;
        this.gender = gender;
        this.age = age;
        this.driverId = driverId;
        this.licenceNumber = licenceNumber;
        this.licenceType = licenceType;
        this.licenceExpiry = licenceExpiry;
        this.experience = experience;
        this.status = status;
        this.createdAt = createdAt;
    }

    // Business logic methods
    public boolean isActive() {
        return status == ConductorStatus.ACTIVE;
    }

    public String getDisplayName() {
        return fullName != null ? fullName : "Unknown Conductor";
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

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }
}
