package com.login.LoginBus.notifications.infra;

import com.login.LoginBus.notifications.domain.NotificationRecipient;
import com.login.LoginBus.notifications.domain.NotificationStatus;
import jakarta.persistence.*;

/**
 * JPA entity for NotificationRecipient.
 * Converts to/from domain NotificationRecipient object.
 */
@Entity
@Table(name = "notification_recipients")
public class NotificationRecipientJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "notification_id", nullable = false)
    private Long notificationId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private NotificationStatus status = NotificationStatus.PENDING;

    @Column(name = "sent_at")
    private Long sentAt;

    @Column(name = "read_at")
    private Long readAt;

    // Constructors
    public NotificationRecipientJpaEntity() {
    }

    public NotificationRecipientJpaEntity(Long notificationId, Long userId) {
        this.notificationId = notificationId;
        this.userId = userId;
        this.status = NotificationStatus.PENDING;
    }

    // Conversion methods
    public NotificationRecipient toDomain() {
        NotificationRecipient recipient = new NotificationRecipient();
        recipient.setId(this.id);
        recipient.setNotificationId(this.notificationId);
        recipient.setUserId(this.userId);
        recipient.setStatus(this.status);
        recipient.setSentAt(this.sentAt);
        recipient.setReadAt(this.readAt);
        return recipient;
    }

    public static NotificationRecipientJpaEntity fromDomain(NotificationRecipient recipient) {
        NotificationRecipientJpaEntity entity = new NotificationRecipientJpaEntity();
        entity.setId(recipient.getId());
        entity.setNotificationId(recipient.getNotificationId());
        entity.setUserId(recipient.getUserId());
        entity.setStatus(recipient.getStatus());
        entity.setSentAt(recipient.getSentAt());
        entity.setReadAt(recipient.getReadAt());
        return entity;
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
