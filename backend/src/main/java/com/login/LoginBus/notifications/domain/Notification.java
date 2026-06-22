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
    private NotificationCategory category;
    private Long createdBy;
    private Long createdAt;

    public Notification() {
    }

    public Notification(
            Long id,
            String title,
            String message,
            NotificationType type,
            NotificationCategory category,
            Long createdBy,
            Long createdAt
    ) {
        this.id = id;
        this.title = title;
        this.message = message;
        this.type = type;
        this.category = category;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
    }

    public boolean isUrgent() {
        return type == NotificationType.URGENT || type == NotificationType.EMERGENCY;
    }

    public String getPreview() {
        if (message == null) {
            return "";
        }
        return message.length() > 50 ? message.substring(0, 50) + "..." : message;
    }

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

    public NotificationCategory getCategory() {
        return category;
    }

    public void setCategory(NotificationCategory category) {
        this.category = category;
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