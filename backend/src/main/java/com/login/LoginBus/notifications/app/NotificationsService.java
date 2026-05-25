package com.login.LoginBus.notifications.app;

import com.login.LoginBus.notifications.api.NotificationWithStatusDto;
import com.login.LoginBus.notifications.domain.Notification;
import com.login.LoginBus.notifications.domain.NotificationRecipient;

import java.util.List;

/**
 * Service interface for notification operations (internal module use).
 */
public interface NotificationsService {

    /**
     * Create a new notification.
     *
     * @param notification Notification to create
     * @return Created notification
     */
    Notification createNotification(Notification notification);

    /**
     * Send notification to specific users.
     *
     * @param notificationId Notification ID
     * @param userIds List of user IDs to send to
     */
    void sendNotificationToUsers(Long notificationId, List<Long> userIds);

    /**
     * Get all notifications for a user.
     *
     * @param userId User ID
     * @return List of notifications
     */
    List<Notification> getNotificationsForUser(Long userId);

    /**
     * Get all notifications for a user, enriched with recipient status fields.
     * Returns the shape expected by the Flutter app (NotificationModel).
     *
     * @param userId User ID
     * @return List of enriched notification DTOs
     */
    List<NotificationWithStatusDto> getNotificationsWithStatusForUser(Long userId);

    /**
     * Get unread notifications for a user.
     *
     * @param userId User ID
     * @return List of unread notifications
     */
    List<Notification> getUnreadNotificationsForUser(Long userId);

    /**
     * Get unread notifications for a user, enriched with recipient status fields.
     *
     * @param userId User ID
     * @return List of enriched unread notification DTOs
     */
    List<NotificationWithStatusDto> getUnreadNotificationsWithStatusForUser(Long userId);

    /**
     * Mark notification as read for a specific user.
     *
     * @param notificationId Notification ID
     * @param userId User ID
     */
    void markNotificationAsRead(Long notificationId, Long userId);

    /**
     * Mark all notifications as read for a user.
     *
     * @param userId User ID
     */
    void markAllAsRead(Long userId);

    /**
     * Get count of unread notifications for a user.
     *
     * @param userId User ID
     * @return Count of unread notifications
     */
    long getUnreadCount(Long userId);

    /**
     * Delete a notification and all its recipients.
     *
     * @param notificationId Notification ID
     */
    void deleteNotification(Long notificationId);
}
