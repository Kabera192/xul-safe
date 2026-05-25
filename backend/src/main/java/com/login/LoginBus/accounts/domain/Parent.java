package com.login.LoginBus.accounts.domain;

/**
 * Pure domain entity for Parent.
 * Contains NO framework annotations - only business logic.
 */
public class Parent {

    private Long id;
    private Long userId;
    private String phoneNumber;
    private String address;
    private Long createdAt;

    // No-arg constructor
    public Parent() {
    }

    // Full constructor
    public Parent(Long id, Long userId, String phoneNumber, String address, Long createdAt) {
        this.id = id;
        this.userId = userId;
        this.phoneNumber = phoneNumber;
        this.address = address;
        this.createdAt = createdAt;
    }

    // Business logic methods
    public boolean hasContactInfo() {
        return phoneNumber != null && !phoneNumber.isEmpty();
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }
}
