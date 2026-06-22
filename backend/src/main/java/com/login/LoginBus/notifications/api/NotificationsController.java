package com.login.LoginBus.notifications.api;

import com.login.LoginBus.notifications.app.NotificationsService;
import com.login.LoginBus.notifications.domain.Notification;
import com.login.LoginBus.shared.api.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import com.login.LoginBus.notifications.domain.NotificationCategory;
import com.login.LoginBus.notifications.domain.NotificationType;

import java.util.List;
import java.util.Map;

/**
 * REST controller for notification operations.
 * All endpoints use /api/v1 prefix for versioning.
 */
@RestController
@RequestMapping("/api/v1/notifications")
@CrossOrigin(origins = "*")
public class NotificationsController {

    @Autowired
    private NotificationsService notificationsService;

    /**
     * Create a new notification and send to users.
     * POST /api/v1/notifications
     *
     * Request body:
     * {
     *   "title": "Important Update",
     *   "message": "Bus schedule has changed",
     *   "type": "INFO",
     *   "userIds": [1, 2, 3]
     * }
     *
     * @param request Request containing notification details and recipient user IDs
     * @return The created notification
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Notification>> createAndSendNotification(
            @RequestBody Map<String, Object> request) {

        if (!request.containsKey("title") || !request.containsKey("message")) {
            throw new IllegalArgumentException("Title and message are required");
        }

        // Create notification
        Notification notification = new Notification();
        notification.setTitle((String) request.get("title"));
        notification.setMessage((String) request.get("message"));

        if (request.containsKey("type")) {
            notification.setType(
                    NotificationType.valueOf(request.get("type").toString())
            );
        } else {
            notification.setType(NotificationType.INFO);
        }

        if (request.containsKey("category")) {
            notification.setCategory(
                    NotificationCategory.valueOf(request.get("category").toString())
            );
        } else {
            notification.setCategory(NotificationCategory.GENERAL);
        }

        if (request.containsKey("createdBy")) {
            notification.setCreatedBy(Long.valueOf(request.get("createdBy").toString()));
        }

        Notification created = notificationsService.createNotification(notification);

        // Send to users if userIds provided
        if (request.containsKey("userIds")) {
            @SuppressWarnings("unchecked")
            List<Integer> userIdsInt = (List<Integer>) request.get("userIds");
            List<Long> userIds = userIdsInt.stream().map(Integer::longValue).toList();
            notificationsService.sendNotificationToUsers(created.getId(), userIds);
        }

        return ResponseEntity.status(HttpStatus.CREATED).body(new ApiResponse<>(
            "Notification created and sent successfully",
            created
        ));
    }

    /**
     * Get all notifications for a user.
     * GET /api/v1/notifications/user/{userId}
     *
     * @param userId User ID
     * @return List of notifications
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<List<Notification>>> getNotificationsForUser(
            @PathVariable Long userId) {

        List<Notification> notifications = notificationsService.getNotificationsForUser(userId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Notifications retrieved successfully",
            notifications
        ));
    }

    /**
     * Get unread notifications for a user.
     * GET /api/v1/notifications/user/{userId}/unread
     *
     * @param userId User ID
     * @return List of unread notifications
     */
    @GetMapping("/user/{userId}/unread")
    public ResponseEntity<ApiResponse<List<Notification>>> getUnreadNotifications(
            @PathVariable Long userId) {

        List<Notification> notifications = notificationsService.getUnreadNotificationsForUser(userId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Unread notifications retrieved successfully",
            notifications
        ));
    }

    /**
     * Get count of unread notifications for a user.
     * GET /api/v1/notifications/user/{userId}/unread/count
     *
     * @param userId User ID
     * @return Count of unread notifications
     */
    @GetMapping("/user/{userId}/unread/count")
    public ResponseEntity<ApiResponse<Long>> getUnreadCount(@PathVariable Long userId) {
        long count = notificationsService.getUnreadCount(userId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Unread count retrieved successfully",
            count
        ));
    }

    /**
     * Mark notification as read.
     * PUT /api/v1/notifications/{notificationId}/read
     *
     * Request body:
     * {
     *   "userId": 1
     * }
     *
     * @param notificationId Notification ID
     * @param request Request containing user ID
     * @return Success message
     */
    @PutMapping("/{notificationId}/read")
    public ResponseEntity<ApiResponse<Void>> markAsRead(
            @PathVariable Long notificationId,
            @RequestBody Map<String, Object> request) {

        if (!request.containsKey("userId")) {
            throw new IllegalArgumentException("User ID is required");
        }

        Long userId = Long.valueOf(request.get("userId").toString());
        notificationsService.markNotificationAsRead(notificationId, userId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Notification marked as read",
            null
        ));
    }

    /**
     * Mark all notifications as read for a user.
     * PUT /api/v1/notifications/user/{userId}/read-all
     *
     * @param userId User ID
     * @return Success message
     */
    @PutMapping("/user/{userId}/read-all")
    public ResponseEntity<ApiResponse<Void>> markAllAsRead(@PathVariable Long userId) {
        notificationsService.markAllAsRead(userId);

        return ResponseEntity.ok(new ApiResponse<>(
            "All notifications marked as read",
            null
        ));
    }

    /**
     * Delete a notification.
     * DELETE /api/v1/notifications/{notificationId}
     *
     * @param notificationId Notification ID
     * @return Success message
     */
    @DeleteMapping("/{notificationId}")
    public ResponseEntity<ApiResponse<Void>> deleteNotification(@PathVariable Long notificationId) {
        notificationsService.deleteNotification(notificationId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Notification deleted successfully",
            null
        ));
    }

    // ── JWT-authenticated "my" endpoints ─────────────────────────────────────

    /**
     * GET /api/v1/notifications/me — get all notifications for the authenticated user.
     * Returns a plain List (no ApiResponse wrapper) matching Flutter NotificationModel.fromApiResponse.
     */
    @GetMapping("/me")
    public ResponseEntity<List<NotificationWithStatusDto>> getMyNotifications(
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = resolveUserId(jwt);
        List<NotificationWithStatusDto> notifications = notificationsService.getNotificationsWithStatusForUser(userId);
        return ResponseEntity.ok(notifications);
    }

    /**
     * GET /api/v1/notifications/me/unread — get unread notifications for the authenticated user.
     * Returns a plain List (no ApiResponse wrapper) matching Flutter NotificationModel.fromApiResponse.
     */
    @GetMapping("/me/unread")
    public ResponseEntity<List<NotificationWithStatusDto>> getMyUnreadNotifications(
            @AuthenticationPrincipal Jwt jwt) {
        Long userId = resolveUserId(jwt);
        List<NotificationWithStatusDto> notifications = notificationsService.getUnreadNotificationsWithStatusForUser(userId);
        return ResponseEntity.ok(notifications);
    }

    /**
     * PATCH /api/v1/notifications/{id}/read — mark a notification as read for the authenticated user.
     */
    @PatchMapping("/{notificationId}/read")
    public ResponseEntity<ApiResponse<Void>> markMyNotificationAsRead(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long notificationId) {
        Long userId = resolveUserId(jwt);
        notificationsService.markNotificationAsRead(notificationId, userId);
        return ResponseEntity.ok(new ApiResponse<>("Notification marked as read", null));
    }

    private Long resolveUserId(Jwt jwt) {
        Long userId = jwt.getClaim("user_id");
        if (userId == null) throw new IllegalArgumentException("Invalid token: missing user_id");
        return userId;
    }
}
