package com.login.LoginBus.notifications.app;

import com.login.LoginBus.notifications.domain.NotificationCategory;
import com.login.LoginBus.notifications.domain.NotificationType;

import java.util.List;

/**
 * Public service interface for Notifications module.
 * Other modules use this interface to send notifications to users.
 *
 * This is the ONLY way other modules should interact with the notifications module.
 */
public interface NotificationsPublicService {

    void sendNotification(
            Long recipientUserId,
            Long createdBy,
            NotificationType type,
            NotificationCategory category,
            String title,
            String message
    );

    void sendNotificationToUsers(
            List<Long> recipientUserIds,
            Long createdBy,
            NotificationType type,
            NotificationCategory category,
            String title,
            String message
    );

    /**
     * Mark a notification as read.
     *
     * @param userId The user ID
     * @param notificationId The notification ID
     */
    void markAsRead(Long userId, Long notificationId);
}