package com.login.LoginBus.accounts.domain;

/**
 * Pure domain entity for User.
 * Contains NO framework annotations - only business logic.
 */
public class User {

    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String password;
    private String phoneNumber;
    private String photoUrl;
    private Long createdAt;
    private UserRole role;

    // No-arg constructor
    public User() {
    }

    // Full constructor
    public User(Long id, String firstName, String lastName, String email,
                String password, String phoneNumber, String photoUrl, Long createdAt, UserRole role) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.password = password;
        this.phoneNumber = phoneNumber;
        this.photoUrl = photoUrl;
        this.createdAt = createdAt;
        this.role = role;
    }

    // Business logic methods
    public String getFullName() {
        return firstName + " " + lastName;
    }

    public boolean hasPhoneNumber() {
        return phoneNumber != null && !phoneNumber.isEmpty();
    }

    public boolean hasPhoto() {
        return photoUrl != null && !photoUrl.isEmpty();
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
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

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }

    public UserRole getRole() {
        return role;
    }

    public void setRole(UserRole role) {
        this.role = role;
    }
}
