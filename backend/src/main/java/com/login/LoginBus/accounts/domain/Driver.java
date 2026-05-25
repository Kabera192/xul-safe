package com.login.LoginBus.accounts.domain;

public class Driver {
    private Long id;
    private Long userId;
    private Long createdAt;

    public Driver() {}

    public Driver(Long id, Long userId, Long createdAt) {
        this.id = id;
        this.userId = userId;
        this.createdAt = createdAt;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public Long getCreatedAt() { return createdAt; }
    public void setCreatedAt(Long createdAt) { this.createdAt = createdAt; }
}
