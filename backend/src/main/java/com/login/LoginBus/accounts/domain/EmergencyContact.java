package com.login.LoginBus.accounts.domain;

/**
 * Pure domain entity for EmergencyContact.
 * Contains NO framework annotations - only business logic.
 */
public class EmergencyContact {

    private Long id;
    private String phoneNumber;
    private String label; // Aunt, Uncle, Houseboy, etc.
    private Long parentId;
    private Long createdAt;

    // No-arg constructor
    public EmergencyContact() {
    }

    // Full constructor
    public EmergencyContact(Long id, String phoneNumber, String label, Long parentId, Long createdAt) {
        this.id = id;
        this.phoneNumber = phoneNumber;
        this.label = label;
        this.parentId = parentId;
        this.createdAt = createdAt;
    }

    // Business logic methods
    public String getDisplayName() {
        return label + ": " + phoneNumber;
    }

    public boolean isValid() {
        return phoneNumber != null && !phoneNumber.trim().isEmpty()
            && label != null && !label.trim().isEmpty();
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public Long getParentId() {
        return parentId;
    }

    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }
}
