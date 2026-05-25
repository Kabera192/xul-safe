package com.login.LoginBus.accounts.api;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDate;

/**
 * Combined DTO that represents a Driver (user account + conductor profile).
 * Used for create, update, and list responses on /api/v1/drivers.
 */
public class DriverAdminDto {

    /** Conductor profile id (primary key in conductors table). */
    private Long id;

    /** Linked user account id. Populated on responses. */
    @JsonProperty("userId")
    private Long userId;

    // ── User account fields ────────────────────────────────────────────────────

    @JsonProperty("firstName")
    private String firstName;

    @JsonProperty("lastName")
    private String lastName;

    private String email;

    /** Write-only — only required when creating a new driver. Never returned. */
    private String password;

    @JsonProperty("phoneNumber")
    private String phoneNumber;

    // ── Conductor profile fields ───────────────────────────────────────────────

    @JsonProperty("fullName")
    private String fullName;

    private String gender;
    private Integer age;

    @JsonProperty("driverId")
    private String driverId;

    @JsonProperty("licenceNumber")
    private String licenceNumber;

    @JsonProperty("licenceType")
    private String licenceType;

    @JsonProperty("licenceExpiry")
    private LocalDate licenceExpiry;

    private String experience;

    @JsonProperty("photoUrl")
    private String photoUrl;

    private String status;

    @JsonProperty("createdAt")
    private Long createdAt;

    public DriverAdminDto() {}

    // ── Getters & Setters ──────────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }

    public String getDriverId() { return driverId; }
    public void setDriverId(String driverId) { this.driverId = driverId; }

    public String getLicenceNumber() { return licenceNumber; }
    public void setLicenceNumber(String licenceNumber) { this.licenceNumber = licenceNumber; }

    public String getLicenceType() { return licenceType; }
    public void setLicenceType(String licenceType) { this.licenceType = licenceType; }

    public LocalDate getLicenceExpiry() { return licenceExpiry; }
    public void setLicenceExpiry(LocalDate licenceExpiry) { this.licenceExpiry = licenceExpiry; }

    public String getExperience() { return experience; }
    public void setExperience(String experience) { this.experience = experience; }

    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Long getCreatedAt() { return createdAt; }
    public void setCreatedAt(Long createdAt) { this.createdAt = createdAt; }
}
