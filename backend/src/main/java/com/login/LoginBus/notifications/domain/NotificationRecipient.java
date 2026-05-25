package com.login.LoginBus.notifications.domain;

/**
 * Pure domain entity for NotificationRecipient.
 * Tracks delivery and read status for each recipient.
 * Contains NO framework annotations - only business logic.
 */
public class NotificationRecipient {

    private Long id;
    private Long notificationId;
    private Long userId;
    private NotificationStatus status;
    private Long sentAt;
    private Long readAt;

    // No-arg constructor
    public NotificationRecipient() {
    }

    // Full constructor
    public NotificationRecipient(Long id, Long notificationId, Long userId,
                                NotificationStatus status, Long sentAt, Long readAt) {
        this.id = id;
        this.notificationId = notificationId;
        this.userId = userId;
        this.status = status;
        this.sentAt = sentAt;
        this.readAt = readAt;
    }

    // Business logic methods
    public boolean isRead() {
        return status == NotificationStatus.READ;
    }

    public boolean isUnread() {
        return status == NotificationStatus.SENT && readAt == null;
    }

    public void markAsRead() {
        this.status = NotificationStatus.READ;
        this.readAt = System.currentTimeMillis();
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(Long notificationId) {
        this.notificationId = notificationId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public NotificationStatus getStatus() {
        return status;
    }

    public void setStatus(NotificationStatus status) {
        this.status = status;
    }

    public Long getSentAt() {
        return sentAt;
    }

    public void setSentAt(Long sentAt) {
        this.sentAt = sentAt;
    }

    public Long getReadAt() {
        return readAt;
    }

    public void setReadAt(Long readAt) {
        this.readAt = readAt;
    }
}
