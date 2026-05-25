package com.login.LoginBus.accounts.infra;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.login.LoginBus.accounts.domain.User;
import com.login.LoginBus.accounts.domain.UserRole;
import jakarta.persistence.*;

/**
 * JPA Entity for User persistence.
 * Handles database mapping and conversion to/from domain entity.
 */
@Entity
@Table(name = "users")
public class UserJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "first_name", nullable = false)
    @JsonProperty("firstName")
    private String firstName;

    @Column(name = "last_name", nullable = false)
    @JsonProperty("lastName")
    private String lastName;

    @Column(nullable = false, unique = true)
    @JsonProperty("email")
    private String email;

    @Column(nullable = false)
    @JsonProperty("password")
    private String password;

    @Column(name = "phone_number", nullable = false)
    @JsonProperty("phoneNumber")
    private String phoneNumber;

    @Column(name = "photo_url", columnDefinition = "TEXT")
    @JsonProperty("photoUrl")
    private String photoUrl;

    @Column(name = "created_at")
    private Long createdAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "role")
    @JsonProperty("role")
    private UserRole role;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = System.currentTimeMillis();
        }
    }

    // No-arg constructor (required for JPA)
    public UserJpaEntity() {
    }

    /**
     * Convert JPA entity to domain entity.
     *
     * @return Domain User entity
     */
    public User toDomain() {
        return new User(
            this.id,
            this.firstName,
            this.lastName,
            this.email,
            this.password,
            this.phoneNumber,
            this.photoUrl,
            this.createdAt,
            this.role
        );
    }

    /**
     * Convert domain entity to JPA entity.
     *
     * @param user Domain User entity
     * @return JPA User entity
     */
    public static UserJpaEntity fromDomain(User user) {
        UserJpaEntity entity = new UserJpaEntity();
        entity.setId(user.getId());
        entity.setFirstName(user.getFirstName());
        entity.setLastName(user.getLastName());
        entity.setEmail(user.getEmail());
        entity.setPassword(user.getPassword());
        entity.setPhoneNumber(user.getPhoneNumber());
        entity.setPhotoUrl(user.getPhotoUrl());
        entity.createdAt = user.getCreatedAt();
        entity.setRole(user.getRole());
        return entity;
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

    public UserRole getRole() {
        return role;
    }

    public void setRole(UserRole role) {
        this.role = role;
    }
}
