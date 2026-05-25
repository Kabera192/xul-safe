package com.login.LoginBus.notifications.infra;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository for NotificationJpaEntity.
 */
@Repository
public interface NotificationRepository extends JpaRepository<NotificationJpaEntity, Long> {

    /**
     * Find notifications by creator.
     *
     * @param createdBy User ID who created the notification
     * @return List of notifications
     */
    List<NotificationJpaEntity> findByCreatedByOrderByCreatedAtDesc(Long createdBy);

    /**
     * Find recent notifications (last 30 days).
     *
     * @param sinceTimestamp Timestamp to filter from
     * @return List of notifications
     */
    @Query("SELECT n FROM NotificationJpaEntity n WHERE n.createdAt >= :sinceTimestamp ORDER BY n.createdAt DESC")
    List<NotificationJpaEntity> findRecentNotifications(@Param("sinceTimestamp") Long sinceTimestamp);
}
