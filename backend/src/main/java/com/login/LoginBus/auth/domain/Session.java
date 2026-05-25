package com.login.LoginBus.auth.domain;

/**
 * Session domain entity - pure business logic.
 * Represents a user authentication session.
 */
public class Session {

    private Long id;
    private Long userId;
    private String token;
    private Long createdAt;
    private Long expiresAt;
    private boolean active;

    // Constructors
    public Session() {
    }

    public Session(Long userId, String token, Long expiresAt) {
        this.userId = userId;
        this.token = token;
        this.createdAt = System.currentTimeMillis();
        this.expiresAt = expiresAt;
        this.active = true;
    }

    // Business logic methods

    /**
     * Check if session is expired.
     *
     * @return true if session is expired
     */
    public boolean isExpired() {
        return System.currentTimeMillis() > expiresAt;
    }

    /**
     * Check if session is valid (active and not expired).
     *
     * @return true if session is valid
     */
    public boolean isValid() {
        return active && !isExpired();
    }

    /**
     * Deactivate this session.
     */
    public void deactivate() {
        this.active = false;
    }

    /**
     * Refresh session expiration time.
     *
     * @param newExpiresAt New expiration timestamp
     */
    public void refreshExpiration(Long newExpiresAt) {
        this.expiresAt = newExpiresAt;
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

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }

    public Long getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(Long expiresAt) {
        this.expiresAt = expiresAt;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
