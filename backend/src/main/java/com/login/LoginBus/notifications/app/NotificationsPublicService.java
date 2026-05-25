package com.login.LoginBus.notifications.app;

import java.util.List;

/**
 * Public service interface for Notifications module.
 * Other modules use this interface to send notifications to users.
 *
 * This is the ONLY way other modules should interact with the notifications module.
 */
public interface NotificationsPublicService {

    /**
     * Send a notification to a single user.
     *
     * @param userId The user ID
     * @param title The notification title
     * @param message The notification message
     */
    void sendNotification(Long userId, String title, String message);

    /**
     * Send notifications to multiple parents.
     *
     * @param parentIds List of parent IDs
     * @param title The notification title
     * @param message The notification message
     */
    void sendNotificationToParents(List<Long> parentIds, String title, String message);

    /**
     * Send a notification to all parents of children on a specific route.
     *
     * @param routeId The route ID
     * @param title The notification title
     * @param message The notification message
     */
    void sendNotificationToRoute(Long routeId, String title, String message);

    /**
     * Mark a notification as read.
     *
     * @param userId The user ID
     * @param notificationId The notification ID
     */
    void markAsRead(Long userId, Long notificationId);
}
