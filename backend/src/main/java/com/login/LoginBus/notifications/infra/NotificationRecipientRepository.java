package com.login.LoginBus.notifications.infra;

import com.login.LoginBus.notifications.domain.NotificationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository for NotificationRecipientJpaEntity.
 */
@Repository
public interface NotificationRecipientRepository extends JpaRepository<NotificationRecipientJpaEntity, Long> {

    /**
     * Find all recipients for a specific notification.
     *
     * @param notificationId Notification ID
     * @return List of recipients
     */
    List<NotificationRecipientJpaEntity> findByNotificationId(Long notificationId);

    /**
     * Find all notifications for a specific user.
     *
     * @param userId User ID
     * @return List of notification recipients
     */
    List<NotificationRecipientJpaEntity> findByUserIdOrderBySentAtDesc(Long userId);

    /**
     * Find unread notifications for a user.
     *
     * @param userId User ID
     * @param status Notification status
     * @return List of unread notification recipients
     */
    List<NotificationRecipientJpaEntity> findByUserIdAndStatus(Long userId, NotificationStatus status);

    /**
     * Count unread notifications for a user.
     *
     * @param userId User ID
     * @param status Notification status (typically READ)
     * @return Count of unread notifications
     */
    @Query("SELECT COUNT(nr) FROM NotificationRecipientJpaEntity nr WHERE nr.userId = :userId AND nr.status <> :status")
    long countUnreadNotifications(@Param("userId") Long userId, @Param("status") NotificationStatus status);
}
