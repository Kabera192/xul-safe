package com.login.LoginBus.accounts.api.dto;

import java.util.List;

/**
 * Profile response DTO.
 * Field names use camelCase to match Flutter DriverProfileModel/ParentProfileModel.fromApiResponse:
 *   userId, firstName, lastName, email, phoneNumber, photoUrl, roles, profileId
 */
public class ProfileResponse {

    private Long userId;
    private String firstName;
    private String lastName;
    private String email;
    private String phoneNumber;
    private String photoUrl;
    private List<String> roles;
    private Long profileId;

    public ProfileResponse() {}

    public ProfileResponse(Long userId, String firstName, String lastName, String email,
                           String phoneNumber, String photoUrl, List<String> roles, Long profileId) {
        this.userId = userId;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.photoUrl = photoUrl;
        this.roles = roles;
        this.profileId = profileId;
    }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    public List<String> getRoles() { return roles; }
    public void setRoles(List<String> roles) { this.roles = roles; }
    public Long getProfileId() { return profileId; }
    public void setProfileId(Long profileId) { this.profileId = profileId; }
}
