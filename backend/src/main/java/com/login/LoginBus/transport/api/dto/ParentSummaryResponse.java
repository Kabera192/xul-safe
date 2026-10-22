package com.login.LoginBus.transport.api.dto;

public class ParentSummaryResponse {

    // Field names match the admin-frontend's ParentSummary model expectations
    private Long id;          // Frontend reads 'id'
    private String fullName;  // Frontend reads 'fullName'
    private String phoneNumber;
    private String email;

    public ParentSummaryResponse() {}

    public ParentSummaryResponse(Long id, String fullName, String phoneNumber, String email) {
        this.id = id;
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.email = email;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
