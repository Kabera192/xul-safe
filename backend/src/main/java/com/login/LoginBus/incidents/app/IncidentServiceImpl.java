package com.login.LoginBus.incidents.app;

import com.login.LoginBus.accounts.app.AccountsPublicService;
import com.login.LoginBus.accounts.domain.User;
import com.login.LoginBus.accounts.domain.UserRole;
import com.login.LoginBus.incidents.api.dto.CreateIncidentRequest;
import com.login.LoginBus.incidents.api.dto.UpdateIncidentRequest;
import com.login.LoginBus.incidents.domain.Incident;
import com.login.LoginBus.incidents.domain.IncidentStatus;
import com.login.LoginBus.incidents.domain.JourneyImpact;
import com.login.LoginBus.incidents.infra.IncidentJpaEntity;
import com.login.LoginBus.incidents.infra.IncidentRepository;
import com.login.LoginBus.notifications.app.NotificationsPublicService;
import com.login.LoginBus.notifications.domain.NotificationCategory;
import com.login.LoginBus.notifications.domain.NotificationType;
import com.login.LoginBus.students.app.StudentsPublicService;
import com.login.LoginBus.students.domain.Child;
import com.login.LoginBus.transport.app.TransportPublicService;
import com.login.LoginBus.transport.domain.Bus;
import com.login.LoginBus.transport.domain.BusTracking;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Service implementation for incident operations.
 */
@Service
public class IncidentServiceImpl implements IncidentService {

    private final IncidentRepository incidentRepository;
    private final AccountsPublicService accountsService;
    private final StudentsPublicService studentsService;
    private final TransportPublicService transportService;
    private final NotificationsPublicService notificationsService;

    public IncidentServiceImpl(
            IncidentRepository incidentRepository,
            AccountsPublicService accountsService,
            StudentsPublicService studentsService,
            TransportPublicService transportService,
            NotificationsPublicService notificationsService
    ) {
        this.incidentRepository = incidentRepository;
        this.accountsService = accountsService;
        this.studentsService = studentsService;
        this.transportService = transportService;
        this.notificationsService = notificationsService;
    }

    @Override
    @Transactional
    public Incident createIncident(Jwt jwt, CreateIncidentRequest request) {
        Long userId = getAuthenticatedUserId(jwt);
        User user = requireAllowedIncidentUser(userId);

        validateCreateRequest(request);

        Set<Long> affectedBusIds = copyLongSet(request.getAffectedBusIds());
        Set<String> affectedChildIds = copyStringSet(request.getAffectedChildIds());

        validateAffectedReferences(affectedBusIds, affectedChildIds);

        if (isTransportUser(user)) {
            validateTransportUserTargets(
                    userId,
                    affectedBusIds,
                    affectedChildIds
            );
        }

        Incident incident = new Incident();
        incident.setType(request.getType());
        incident.setDescription(request.getDescription().trim());
        incident.setJourneyImpact(request.getJourneyImpact());

        // Lifecycle information is controlled by the backend.
        incident.setStatus(IncidentStatus.ACTIVE);
        incident.setCreatedBy(userId);
        incident.setCreatedAt(System.currentTimeMillis());
        incident.setResolvedBy(null);
        incident.setResolvedAt(null);

        incident.setAffectedBusIds(affectedBusIds);
        incident.setAffectedChildIds(affectedChildIds);

        /*
         * Capture the active transport sessions that existed when the
         * incident was created.
         *
         * These IDs are historical context and are not recalculated later.
         */
        Set<String> trackingIds = new HashSet<>();

        for (Long busId : affectedBusIds) {
            BusTracking tracking =
                    transportService.getActiveBusTrackingForBus(busId);

            if (tracking != null && tracking.getId() != null) {
                trackingIds.add(tracking.getId());
            }
        }

        /*
         * A transport user may report a child-specific incident without
         * declaring the whole bus as affected.
         *
         * In that case we still preserve the current tracking session of
         * their assigned bus as useful context, without turning the bus
         * itself into an affected target.
         */
        if (isTransportUser(user) && affectedBusIds.isEmpty()) {
            Bus assignedBus = transportService.getAssignedBusForUser(userId);

            if (assignedBus != null) {
                BusTracking tracking =
                        transportService.getActiveBusTrackingForBus(
                                assignedBus.getId()
                        );

                if (tracking != null && tracking.getId() != null) {
                    trackingIds.add(tracking.getId());
                }
            }
        }

        incident.setRelatedTrackingIds(trackingIds);

        IncidentJpaEntity saved =
                incidentRepository.save(
                        IncidentJpaEntity.fromDomain(incident)
                );

        Incident created = saved.toDomain();

        sendIncidentNotifications(created);

        return created;
    }

    @Override
    @Transactional(readOnly = true)
    public Incident getIncidentById(Long incidentId) {
        return incidentRepository.findById(incidentId)
                .map(IncidentJpaEntity::toDomain)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Incident not found with ID: " + incidentId
                        )
                );
    }

    @Override
    @Transactional(readOnly = true)
    public List<Incident> getAllIncidents() {
        return incidentRepository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(IncidentJpaEntity::toDomain)
                .collect(Collectors.toList());
    }

    @Override
@Transactional(readOnly = true)
public List<Incident> getMyIncidents(Jwt jwt) {
    Long userId = getAuthenticatedUserId(jwt);
    User user = requireAllowedIncidentUser(userId);

    if (!isTransportUser(user)) {
        throw new IllegalArgumentException(
                "Only DRIVER or CONDUCTOR users can retrieve transport-user incidents"
        );
    }

    Bus assignedBus =
            transportService.getAssignedBusForUser(userId);

    Long assignedBusId =
            assignedBus != null ? assignedBus.getId() : null;

    Set<String> assignedChildIds =
            assignedBusId == null
                    ? new HashSet<>()
                    : studentsService.getChildrenForBus(assignedBusId)
                            .stream()
                            .map(Child::getId)
                            .filter(Objects::nonNull)
                            .collect(Collectors.toSet());

    return incidentRepository.findAllByOrderByCreatedAtDesc()
            .stream()
            .filter(entity ->
                    isIncidentRelatedToTransportUser(
                            entity,
                            userId,
                            assignedBusId,
                            assignedChildIds
                    )
            )
            .map(IncidentJpaEntity::toDomain)
            .collect(Collectors.toList());
}

    @Override
    @Transactional
    public Incident updateIncident(
            Long incidentId,
            Jwt jwt,
            UpdateIncidentRequest request
    ) {
        Long userId = getAuthenticatedUserId(jwt);
        User user = requireAllowedIncidentUser(userId);

        IncidentJpaEntity entity = incidentRepository.findById(incidentId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Incident not found with ID: " + incidentId
                        )
                );
                if (isTransportUser(user)) {
                        validateTransportUserCreatedIncident(
                                userId,
                                entity
                        );
                        }

        if (entity.getStatus() == IncidentStatus.RESOLVED) {
            throw new IllegalArgumentException(
                    "Resolved incidents cannot be updated"
            );
        }

        if (request == null) {
            throw new IllegalArgumentException(
                    "Incident update request is required"
            );
        }

        if (request.getDescription() != null) {
            if (request.getDescription().trim().isEmpty()) {
                throw new IllegalArgumentException(
                        "Incident description cannot be empty"
                );
            }

            entity.setDescription(
                    request.getDescription().trim()
            );
        }

        if (request.getJourneyImpact() != null) {
            entity.setJourneyImpact(
                    request.getJourneyImpact()
            );
        }

        Set<Long> finalBusIds =
                new HashSet<>(entity.getAffectedBusIds());

        Set<String> finalChildIds =
                new HashSet<>(entity.getAffectedChildIds());

        if (request.getAffectedBusIds() != null) {
            finalBusIds =
                    copyLongSet(request.getAffectedBusIds());
        }

        if (request.getAffectedChildIds() != null) {
            finalChildIds =
                    copyStringSet(request.getAffectedChildIds());
        }

        validateAffectedReferences(
                finalBusIds,
                finalChildIds
        );

        if (isTransportUser(user)) {
            validateTransportUserTargets(
                    userId,
                    finalBusIds,
                    finalChildIds
            );
        }

        entity.setAffectedBusIds(finalBusIds);
        entity.setAffectedChildIds(finalChildIds);

        /*
         * relatedTrackingIds are intentionally NOT changed.
         *
         * They record the transport context that existed when the incident
         * was originally reported.
         */

        return incidentRepository.save(entity).toDomain();
    }

    @Override
    @Transactional
    public Incident resolveIncident(
            Long incidentId,
            Jwt jwt
    ) {
        Long userId = getAuthenticatedUserId(jwt);
        User user = requireAllowedIncidentUser(userId);

        IncidentJpaEntity entity = incidentRepository.findById(incidentId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Incident not found with ID: " + incidentId
                        )
                );
                

        if (entity.getStatus() == IncidentStatus.RESOLVED) {
            throw new IllegalArgumentException(
                    "Incident is already resolved"
            );
        }

        /*
        * Transport users may only resolve incidents they created.
        *
        * Visibility of another related incident does not grant management rights.
        */
        if (isTransportUser(user)) {
        validateTransportUserCreatedIncident(
                userId,
                entity
        );
        }

        entity.setStatus(IncidentStatus.RESOLVED);
        entity.setResolvedBy(userId);
        entity.setResolvedAt(System.currentTimeMillis());

        return incidentRepository.save(entity).toDomain();
    }

    private void validateCreateRequest(
            CreateIncidentRequest request
    ) {
        if (request == null) {
            throw new IllegalArgumentException(
                    "Incident request is required"
            );
        }

        if (request.getType() == null) {
            throw new IllegalArgumentException(
                    "Incident type is required"
            );
        }

        if (request.getDescription() == null
                || request.getDescription().trim().isEmpty()) {
            throw new IllegalArgumentException(
                    "Incident description is required"
            );
        }

        if (request.getJourneyImpact() == null) {
            throw new IllegalArgumentException(
                    "Journey impact is required"
            );
        }
    }

    private void validateAffectedReferences(
            Set<Long> busIds,
            Set<String> childIds
    ) {
        validateBusReferences(busIds);
        validateChildReferences(childIds);
    }

    private void validateBusReferences(
            Set<Long> busIds
    ) {
        for (Long busId : busIds) {
            if (busId == null
                    || transportService.getBusById(busId) == null) {
                throw new IllegalArgumentException(
                        "Bus not found with ID: " + busId
                );
            }
        }
    }

    private void validateChildReferences(
            Set<String> childIds
    ) {
        for (String childId : childIds) {
            if (childId == null
                    || childId.isBlank()
                    || !studentsService.childExists(childId)) {
                throw new IllegalArgumentException(
                        "Child not found with ID: " + childId
                );
            }
        }
    }

    /**
     * Driver/conductor restrictions:
     *
     * - Any explicitly affected bus must be their assigned bus.
     * - Any explicitly affected child must belong to their assigned bus.
     * - They must actually have an assigned bus.
     *
     * We do NOT automatically mark their bus as affected. This allows
     * child-specific incidents to remain child-specific.
     */
    private void validateTransportUserTargets(
            Long userId,
            Set<Long> busIds,
            Set<String> childIds
    ) {
        Bus assignedBus =
                transportService.getAssignedBusForUser(userId);

        if (assignedBus == null) {
            throw new IllegalArgumentException(
                    "No bus is assigned to the authenticated transport user"
            );
        }

        Long assignedBusId = assignedBus.getId();

        for (Long busId : busIds) {
            if (!assignedBusId.equals(busId)) {
                throw new IllegalArgumentException(
                        "Transport users can only manage incidents for their assigned bus"
                );
            }
        }

        for (String childId : childIds) {
            Child child = studentsService.getChildById(childId);

            if (child == null
                    || child.getBusId() == null
                    || !assignedBusId.equals(child.getBusId())) {
                throw new IllegalArgumentException(
                        "Transport users can only manage incidents involving children assigned to their bus"
                );
            }
        }
    }

    private boolean isIncidentRelatedToTransportUser(
        IncidentJpaEntity incident,
        Long userId,
        Long assignedBusId,
        Set<String> assignedChildIds
) {
    if (Objects.equals(
            incident.getCreatedBy(),
            userId
    )) {
        return true;
    }

    if (assignedBusId != null
            && incident.getAffectedBusIds() != null
            && incident.getAffectedBusIds().contains(assignedBusId)) {
        return true;
    }

    if (incident.getAffectedChildIds() != null
            && !incident.getAffectedChildIds().isEmpty()
            && !assignedChildIds.isEmpty()) {

        return incident.getAffectedChildIds()
                .stream()
                .anyMatch(assignedChildIds::contains);
    }

    return false;
}

private void validateTransportUserCreatedIncident(
        Long userId,
        IncidentJpaEntity incident
) {
    if (!Objects.equals(
            incident.getCreatedBy(),
            userId
    )) {
        throw new IllegalArgumentException(
                "Transport users can only modify or resolve incidents they created"
        );
    }
}

    private User requireAllowedIncidentUser(
            Long userId
    ) {
        User user = accountsService.getUserById(userId);

        if (user == null) {
            throw new IllegalArgumentException(
                    "Authenticated user not found"
            );
        }

        if (user.getRole() != UserRole.ADMIN
                && user.getRole() != UserRole.DRIVER
                && user.getRole() != UserRole.CONDUCTOR) {
            throw new IllegalArgumentException(
                    "Only ADMIN, DRIVER, or CONDUCTOR users can manage incidents"
            );
        }

        return user;
    }

    private boolean isTransportUser(User user) {
        return user.getRole() == UserRole.DRIVER
                || user.getRole() == UserRole.CONDUCTOR;
    }

    private Long getAuthenticatedUserId(
            Jwt jwt
    ) {
        if (jwt == null) {
            throw new IllegalArgumentException(
                    "Authentication is required"
            );
        }

        Object userIdClaim = jwt.getClaim("user_id");

        if (userIdClaim == null) {
            throw new IllegalArgumentException(
                    "Authenticated user ID is missing"
            );
        }

        try {
            return Long.valueOf(
                    userIdClaim.toString()
            );
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(
                    "Invalid authenticated user ID"
            );
        }
    }

    /**
     * Notification targeting:
     *
     * - Admins always receive the notification.
     * - Parents of explicitly affected children receive it.
     * - Parents from affected buses are included when the incident is
     *   actually disrupting the journey.
     *
     * This prevents a child-only NONE-impact incident, such as two children
     * fighting while the bus continues normally, from being announced to
     * every parent on that bus.
     */
    private void sendIncidentNotifications(
            Incident incident
    ) {
        try {
            Set<Long> adminIds = accountsService
                    .getUsersByRole(UserRole.ADMIN)
                    .stream()
                    .map(User::getId)
                    .filter(Objects::nonNull)
                    .collect(Collectors.toSet());

            Set<Long> affectedChildParentIds = new HashSet<>();

            for (String childId : incident.getAffectedChildIds()) {
                Child child = studentsService.getChildById(childId);

                if (child != null && child.getParentId() != null) {
                    affectedChildParentIds.add(child.getParentId());
                }
            }

            /*
             * Admins and parents of directly affected children may receive
             * the actual incident description.
             */
            Set<Long> detailedRecipients = new HashSet<>(adminIds);
            detailedRecipients.addAll(affectedChildParentIds);

            /*
             * A bus-only incident has no child-specific private detail, so
             * parents on the affected bus can receive the normal description.
             */
            if (incident.getAffectedChildIds().isEmpty()) {
                for (Long busId : incident.getAffectedBusIds()) {
                    for (Child child : studentsService.getChildrenForBus(busId)) {
                        if (child.getParentId() != null) {
                            detailedRecipients.add(child.getParentId());
                        }
                    }
                }
            }

            if (!detailedRecipients.isEmpty()) {
                notificationsService.sendNotificationToUsers(
                        List.copyOf(detailedRecipients),
                        incident.getCreatedBy(),
                        notificationTypeFor(incident),
                        NotificationCategory.INCIDENT_REPORTED,
                        "Incident reported",
                        incident.getDescription()
                );
            }

            /*
             * If specific children are involved but the incident also delays
             * or stops the bus, the remaining bus parents still need to know
             * about the transport disruption.
             *
             * They do NOT receive the child-specific description.
             */
            if (!incident.getAffectedChildIds().isEmpty()
                    && incident.getJourneyImpact() != JourneyImpact.NONE) {

                Set<Long> operationalRecipients = new HashSet<>();

                for (Long busId : incident.getAffectedBusIds()) {
                    for (Child child : studentsService.getChildrenForBus(busId)) {
                        if (child.getParentId() != null) {
                            operationalRecipients.add(child.getParentId());
                        }
                    }
                }

                // They already received the detailed message.
                operationalRecipients.removeAll(affectedChildParentIds);

                // Admins already received the detailed message as well.
                operationalRecipients.removeAll(adminIds);

                if (!operationalRecipients.isEmpty()) {
                    String operationalMessage =
                            incident.getJourneyImpact() == JourneyImpact.STOPPED
                                    ? "The bus journey has been stopped due to an active incident."
                                    : "The bus journey is delayed due to an active incident.";

                    notificationsService.sendNotificationToUsers(
                            List.copyOf(operationalRecipients),
                            incident.getCreatedBy(),
                            notificationTypeFor(incident),
                            NotificationCategory.INCIDENT_REPORTED,
                            "Journey affected by incident",
                            operationalMessage
                    );
                }
            }

        } catch (Exception e) {
            /*
             * Thrown as IllegalArgumentException (not IllegalStateException)
             * so it maps to HTTP 400 in IncidentExceptionHandler — the
             * admin frontend's error interceptor only surfaces the real
             * server-provided message for 400s; 500s are shown generically.
             */
            throw new IllegalArgumentException(
                    "Incident was not reported: failed to notify recipients ("
                            + e.getMessage() + ")",
                    e
            );
        }
    }

    private NotificationType notificationTypeFor(
            Incident incident
    ) {
        return switch (incident.getJourneyImpact()) {
            case NONE ->
                    NotificationType.INFO;

            case DELAYED ->
                    NotificationType.WARNING;

            case STOPPED ->
                    NotificationType.URGENT;
        };
    }

    private Set<Long> copyLongSet(
            Set<Long> values
    ) {
        return values == null
                ? new HashSet<>()
                : new HashSet<>(values);
    }

    private Set<String> copyStringSet(
            Set<String> values
    ) {
        return values == null
                ? new HashSet<>()
                : new HashSet<>(values);
    }
}