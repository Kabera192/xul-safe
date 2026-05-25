package com.login.LoginBus.notifications.domain;

/**
 * Pure domain entity for Notification.
 * Contains NO framework annotations - only business logic.
 */
public class Notification {

    private Long id;
    private String title;
    private String message;
    private NotificationType type;
    private Long createdBy;
    private Long createdAt;

    // No-arg constructor
    public Notification() {
    }

    // Full constructor
    public Notification(Long id, String title, String message, NotificationType type,
                       Long createdBy, Long createdAt) {
        this.id = id;
        this.title = title;
        this.message = message;
        this.type = type;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
    }

    // Business logic methods
    public boolean isUrgent() {
        return type == NotificationType.URGENT || type == NotificationType.EMERGENCY;
    }

    public String getPreview() {
        if (message == null) {
            return "";
        }
        return message.length() > 50 ? message.substring(0, 50) + "..." : message;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public NotificationType getType() {
        return type;
    }

    public void setType(NotificationType type) {
        this.type = type;
    }

    public Long getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Long createdBy) {
        this.createdBy = createdBy;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }
}
