package com.login.LoginBus.notifications.app;

import com.login.LoginBus.notifications.api.NotificationWithStatusDto;
import com.login.LoginBus.notifications.domain.Notification;
import com.login.LoginBus.notifications.domain.NotificationRecipient;
import com.login.LoginBus.notifications.domain.NotificationStatus;
import com.login.LoginBus.notifications.infra.NotificationJpaEntity;
import com.login.LoginBus.notifications.infra.NotificationRecipientJpaEntity;
import com.login.LoginBus.notifications.infra.NotificationRecipientRepository;
import com.login.LoginBus.notifications.infra.NotificationRepository;
import com.login.LoginBus.notifications.domain.NotificationCategory;
import com.login.LoginBus.notifications.domain.NotificationType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Implementation of NotificationsService.
 * Also implements NotificationsPublicService for cross-module communication.
 */
@Service
public class NotificationsServiceImpl implements NotificationsService, NotificationsPublicService {

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private NotificationRecipientRepository recipientRepository;

    @Override
    @Transactional
    public Notification createNotification(Notification notification) {
        NotificationJpaEntity entity = NotificationJpaEntity.fromDomain(notification);
        NotificationJpaEntity saved = notificationRepository.save(entity);
        return saved.toDomain();
    }

    @Override
    @Transactional
    public void sendNotificationToUsers(Long notificationId, List<Long> userIds) {
        if (userIds == null || userIds.isEmpty()) {
            throw new IllegalArgumentException("User IDs list cannot be empty");
        }

        Optional<NotificationJpaEntity> notificationOpt = notificationRepository.findById(notificationId);
        if (notificationOpt.isEmpty()) {
            throw new IllegalArgumentException("Notification not found with ID: " + notificationId);
        }

        List<NotificationRecipientJpaEntity> recipients = new ArrayList<>();
        for (Long userId : userIds) {
            NotificationRecipientJpaEntity recipient = new NotificationRecipientJpaEntity(notificationId, userId);
            recipient.setStatus(NotificationStatus.SENT);
            recipient.setSentAt(System.currentTimeMillis());
            recipients.add(recipient);
        }

        recipientRepository.saveAll(recipients);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Notification> getNotificationsForUser(Long userId) {
        List<NotificationRecipientJpaEntity> recipients = recipientRepository.findByUserIdOrderBySentAtDesc(userId);

        return recipients.stream()
                .map(recipient -> {
                    Optional<NotificationJpaEntity> notificationOpt =
                        notificationRepository.findById(recipient.getNotificationId());
                    return notificationOpt.map(NotificationJpaEntity::toDomain).orElse(null);
                })
                .filter(notification -> notification != null)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<NotificationWithStatusDto> getNotificationsWithStatusForUser(Long userId) {
        List<NotificationRecipientJpaEntity> recipients = recipientRepository.findByUserIdOrderBySentAtDesc(userId);

        return recipients.stream()
                .map(recipient -> {
                    Optional<NotificationJpaEntity> notOpt =
                        notificationRepository.findById(recipient.getNotificationId());
                    if (notOpt.isEmpty()) return null;
                    NotificationJpaEntity not = notOpt.get();
                    return new NotificationWithStatusDto(
                            not.getId(),
                            not.getTitle(),
                            not.getMessage(),
                            not.getType() != null ? not.getType().name() : "INFO",
                            not.getCategory() != null ? not.getCategory().name() : "GENERAL",
                            not.getCreatedBy(),
                            recipient.getUserId(),
                            recipient.getStatus() != null ? recipient.getStatus().name() : "SENT",
                            recipient.getSentAt(),
                            recipient.getReadAt()
                    );
                })
                .filter(dto -> dto != null)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<Notification> getUnreadNotificationsForUser(Long userId) {
        List<NotificationRecipientJpaEntity> recipients =
            recipientRepository.findByUserIdAndStatus(userId, NotificationStatus.SENT);

        return recipients.stream()
                .map(recipient -> {
                    Optional<NotificationJpaEntity> notificationOpt =
                        notificationRepository.findById(recipient.getNotificationId());
                    return notificationOpt.map(NotificationJpaEntity::toDomain).orElse(null);
                })
                .filter(notification -> notification != null)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<NotificationWithStatusDto> getUnreadNotificationsWithStatusForUser(Long userId) {
        List<NotificationRecipientJpaEntity> recipients =
            recipientRepository.findByUserIdAndStatus(userId, NotificationStatus.SENT);

        return recipients.stream()
                .map(recipient -> {
                    Optional<NotificationJpaEntity> notOpt =
                        notificationRepository.findById(recipient.getNotificationId());
                    if (notOpt.isEmpty()) return null;
                    NotificationJpaEntity not = notOpt.get();
                    return new NotificationWithStatusDto(
                            not.getId(),
                            not.getTitle(),
                            not.getMessage(),
                            not.getType() != null ? not.getType().name() : "INFO",
                            not.getCategory() != null ? not.getCategory().name() : "GENERAL",
                            not.getCreatedBy(),
                            recipient.getUserId(),
                            recipient.getStatus() != null ? recipient.getStatus().name() : "SENT",
                            recipient.getSentAt(),
                            recipient.getReadAt()
                    );
                })
                .filter(dto -> dto != null)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void markNotificationAsRead(Long notificationId, Long userId) {
        List<NotificationRecipientJpaEntity> recipients = recipientRepository.findByNotificationId(notificationId);

        for (NotificationRecipientJpaEntity recipient : recipients) {
            if (recipient.getUserId().equals(userId)) {
                recipient.setStatus(NotificationStatus.READ);
                recipient.setReadAt(System.currentTimeMillis());
                recipientRepository.save(recipient);
                break;
            }
        }
    }

    @Override
    @Transactional
    public void markAllAsRead(Long userId) {
        List<NotificationRecipientJpaEntity> unreadRecipients =
            recipientRepository.findByUserIdAndStatus(userId, NotificationStatus.SENT);

        for (NotificationRecipientJpaEntity recipient : unreadRecipients) {
            recipient.setStatus(NotificationStatus.READ);
            recipient.setReadAt(System.currentTimeMillis());
        }

        recipientRepository.saveAll(unreadRecipients);
    }

    @Override
    @Transactional(readOnly = true)
    public long getUnreadCount(Long userId) {
        return recipientRepository.countUnreadNotifications(userId, NotificationStatus.READ);
    }

    @Override
    @Transactional
    public void deleteNotification(Long notificationId) {
        List<NotificationRecipientJpaEntity> recipients = recipientRepository.findByNotificationId(notificationId);
        recipientRepository.deleteAll(recipients);
        notificationRepository.deleteById(notificationId);
    }

    // Public service methods (for cross-module communication)

    // Public service methods (for cross-module communication)

    @Override
    @Transactional
    public void sendNotification(
            Long recipientUserId,
            Long createdBy,
            NotificationType type,
            NotificationCategory category,
            String title,
            String message
    ) {
        if (recipientUserId == null) {
            return;
        }

        List<Long> recipientUserIds = new ArrayList<>();
        recipientUserIds.add(recipientUserId);

        sendNotificationToUsers(
                recipientUserIds,
                createdBy,
                type,
                category,
                title,
                message
        );
    }

    @Override
    @Transactional
    public void sendNotificationToUsers(
            List<Long> recipientUserIds,
            Long createdBy,
            NotificationType type,
            NotificationCategory category,
            String title,
            String message
    ) {
        if (recipientUserIds == null || recipientUserIds.isEmpty()) {
            return;
        }

        Notification notification = new Notification();
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setType(type != null ? type : NotificationType.INFO);
        notification.setCategory(category != null ? category : NotificationCategory.GENERAL);
        notification.setCreatedBy(createdBy);

        Notification created = createNotification(notification);
        sendNotificationToUsers(created.getId(), recipientUserIds);
    }
    @Override
    @Transactional
    public void markAsRead(Long userId, Long notificationId) {
        markNotificationAsRead(notificationId, userId);
    }
}
