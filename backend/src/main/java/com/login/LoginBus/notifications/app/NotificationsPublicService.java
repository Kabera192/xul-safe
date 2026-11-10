package com.login.LoginBus.notifications.app;

import com.login.LoginBus.notifications.domain.NotificationCategory;
import com.login.LoginBus.notifications.domain.NotificationType;

import java.util.List;
import java.util.Map;

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

    /**
     * Same as above, but with structured params the recipient's own app can
     * use to render this notification in their chosen language — e.g.
     * {"childName": "Amina", "session": "MORNING"} for a category the
     * client knows how to localize. title/message stay as the English
     * fallback for categories the client doesn't recognize.
     */
    void sendNotification(
            Long recipientUserId,
            Long createdBy,
            NotificationType type,
            NotificationCategory category,
            String title,
            String message,
            Map<String, String> params
    );

    void sendNotificationToUsers(
            List<Long> recipientUserIds,
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
            String message,
            Map<String, String> params
    );

    /**
     * Mark a notification as read.
     *
     * @param userId The user ID
     * @param notificationId The notification ID
     */
    void markAsRead(Long userId, Long notificationId);
}