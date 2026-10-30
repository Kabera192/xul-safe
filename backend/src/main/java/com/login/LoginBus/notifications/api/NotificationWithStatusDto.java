package com.login.LoginBus.notifications.api;

import java.util.Map;

/**
 * Notification response enriched with the recipient's status fields.
 * Field names use camelCase to match Flutter NotificationModel.fromApiResponse:
 *   notificationId, title, message, type, category, params, createdBy, recipientUserId, status, sentAt, readAt
 */
public class NotificationWithStatusDto {

    private Long notificationId;
    private String title;
    private String message;
    private String type;
    private String category;
    private Map<String, String> params;
    private Long createdBy;
    private Long recipientUserId;
    private String status;
    private Long sentAt;
    private Long readAt;

    public NotificationWithStatusDto() {
    }

    public NotificationWithStatusDto(
            Long notificationId,
            String title,
            String message,
            String type,
            String category,
            Map<String, String> params,
            Long createdBy,
            Long recipientUserId,
            String status,
            Long sentAt,
            Long readAt
    ) {
        this.notificationId = notificationId;
        this.title = title;
        this.message = message;
        this.type = type;
        this.category = category;
        this.params = params;
        this.createdBy = createdBy;
        this.recipientUserId = recipientUserId;
        this.status = status;
        this.sentAt = sentAt;
        this.readAt = readAt;
    }

    public Long getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(Long notificationId) {
        this.notificationId = notificationId;
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

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public Map<String, String> getParams() {
        return params;
    }

    public void setParams(Map<String, String> params) {
        this.params = params;
    }

    public Long getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Long createdBy) {
        this.createdBy = createdBy;
    }

    public Long getRecipientUserId() {
        return recipientUserId;
    }

    public void setRecipientUserId(Long recipientUserId) {
        this.recipientUserId = recipientUserId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
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