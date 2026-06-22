package com.login.LoginBus.notifications.infra;

import com.login.LoginBus.notifications.domain.Notification;
import com.login.LoginBus.notifications.domain.NotificationCategory;
import com.login.LoginBus.notifications.domain.NotificationType;
import jakarta.persistence.*;

/**
 * JPA entity for Notification.
 * Converts to/from domain Notification object.
 */
@Entity
@Table(name = "notifications")
public class NotificationJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false, length = 1000)
    private String message;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private NotificationType type;

    @Enumerated(EnumType.STRING)
    @Column(name = "category", nullable = false, length = 80)
    private NotificationCategory category;

    @Column(name = "created_by")
    private Long createdBy;

    @Column(name = "created_at")
    private Long createdAt;

    public NotificationJpaEntity() {
    }

    public NotificationJpaEntity(
            String title,
            String message,
            NotificationType type,
            NotificationCategory category,
            Long createdBy
    ) {
        this.title = title;
        this.message = message;
        this.type = type;
        this.category = category;
        this.createdBy = createdBy;
        this.createdAt = System.currentTimeMillis();
    }

    public Notification toDomain() {
        Notification notification = new Notification();
        notification.setId(this.id);
        notification.setTitle(this.title);
        notification.setMessage(this.message);
        notification.setType(this.type);
        notification.setCategory(this.category);
        notification.setCreatedBy(this.createdBy);
        notification.setCreatedAt(this.createdAt);
        return notification;
    }

    public static NotificationJpaEntity fromDomain(Notification notification) {
        NotificationJpaEntity entity = new NotificationJpaEntity();
        entity.setId(notification.getId());
        entity.setTitle(notification.getTitle());
        entity.setMessage(notification.getMessage());
        entity.setType(notification.getType());
        entity.setCategory(notification.getCategory());
        entity.setCreatedBy(notification.getCreatedBy());
        entity.setCreatedAt(notification.getCreatedAt());
        return entity;
    }

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = System.currentTimeMillis();
        }

        if (type == null) {
            type = NotificationType.INFO;
        }

        if (category == null) {
            category = NotificationCategory.GENERAL;
        }
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