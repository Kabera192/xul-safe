package com.login.LoginBus.incidents.app;

import com.login.LoginBus.accounts.app.AccountsPublicService;
import com.login.LoginBus.accounts.domain.User;
import com.login.LoginBus.accounts.domain.UserRole;
import com.login.LoginBus.incidents.api.dto.UpdateIncidentRequest;
import com.login.LoginBus.incidents.domain.IncidentStatus;
import com.login.LoginBus.incidents.domain.IncidentType;
import com.login.LoginBus.incidents.domain.JourneyImpact;
import com.login.LoginBus.incidents.infra.IncidentJpaEntity;
import com.login.LoginBus.incidents.infra.IncidentRepository;
import com.login.LoginBus.notifications.app.NotificationsPublicService;
import com.login.LoginBus.students.app.StudentsPublicService;
import com.login.LoginBus.transport.app.TransportPublicService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.Jwt;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class IncidentUpdateResolveTest {

    private IncidentRepository incidentRepository;
    private AccountsPublicService accountsService;
    private StudentsPublicService studentsService;
    private TransportPublicService transportService;
    private NotificationsPublicService notificationsService;

    private IncidentServiceImpl service;

    @BeforeEach
    void setUp() {
        incidentRepository = mock(IncidentRepository.class);
        accountsService = mock(AccountsPublicService.class);
        studentsService = mock(StudentsPublicService.class);
        transportService = mock(TransportPublicService.class);
        notificationsService = mock(NotificationsPublicService.class);

        service = new IncidentServiceImpl(
                incidentRepository,
                accountsService,
                studentsService,
                transportService,
                notificationsService
        );

        when(accountsService.getUserById(1L))
                .thenReturn(user(1L, UserRole.ADMIN));
    }

    @Test
    void activeIncidentCanUpdateDescriptionAndJourneyImpact() {
        IncidentJpaEntity entity = activeIncident();

        when(incidentRepository.findById(50L))
                .thenReturn(Optional.of(entity));

        when(incidentRepository.save(any(IncidentJpaEntity.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        UpdateIncidentRequest request = new UpdateIncidentRequest();
        request.setDescription(
                "Wheel damage is worse than initially expected"
        );
        request.setJourneyImpact(JourneyImpact.STOPPED);

        var updated = service.updateIncident(
                50L,
                jwtFor(1L),
                request
        );

        assertEquals(
                "Wheel damage is worse than initially expected",
                updated.getDescription()
        );

        assertEquals(
                JourneyImpact.STOPPED,
                updated.getJourneyImpact()
        );

        // Type stays fixed.
        assertEquals(
                IncidentType.VEHICLE_BREAKDOWN,
                updated.getType()
        );
    }

    @Test
    void updatingIncidentDoesNotReplaceOriginalTrackingIds() {
        IncidentJpaEntity entity = activeIncident();
        entity.setRelatedTrackingIds(
                Set.of("original-tracking")
        );

        when(incidentRepository.findById(50L))
                .thenReturn(Optional.of(entity));

        when(incidentRepository.save(any(IncidentJpaEntity.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        UpdateIncidentRequest request = new UpdateIncidentRequest();
        request.setJourneyImpact(JourneyImpact.STOPPED);

        var updated = service.updateIncident(
                50L,
                jwtFor(1L),
                request
        );

        assertEquals(
                Set.of("original-tracking"),
                updated.getRelatedTrackingIds()
        );

        verify(
                transportService,
                never()
        ).getActiveBusTrackingForBus(anyLong());
    }

    @Test
    void resolveRecordsResolverAndResolutionTime() {
        IncidentJpaEntity entity = activeIncident();

        when(incidentRepository.findById(50L))
                .thenReturn(Optional.of(entity));

        when(incidentRepository.save(any(IncidentJpaEntity.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        long before = System.currentTimeMillis();

        var resolved = service.resolveIncident(
                50L,
                jwtFor(1L)
        );

        long after = System.currentTimeMillis();

        assertEquals(
                IncidentStatus.RESOLVED,
                resolved.getStatus()
        );

        assertEquals(
                1L,
                resolved.getResolvedBy()
        );

        assertNotNull(
                resolved.getResolvedAt()
        );

        assertTrue(
                resolved.getResolvedAt() >= before
        );

        assertTrue(
                resolved.getResolvedAt() <= after
        );
    }

    @Test
    void resolvedIncidentCannotBeUpdated() {
        IncidentJpaEntity entity = activeIncident();
        entity.setStatus(IncidentStatus.RESOLVED);
        entity.setResolvedBy(1L);
        entity.setResolvedAt(System.currentTimeMillis());

        when(incidentRepository.findById(50L))
                .thenReturn(Optional.of(entity));

        UpdateIncidentRequest request =
                new UpdateIncidentRequest();

        request.setDescription("Should not work");

        IllegalArgumentException exception =
                assertThrows(
                        IllegalArgumentException.class,
                        () -> service.updateIncident(
                                50L,
                                jwtFor(1L),
                                request
                        )
                );

        assertEquals(
                "Resolved incidents cannot be updated",
                exception.getMessage()
        );

        verify(
                incidentRepository,
                never()
        ).save(any(IncidentJpaEntity.class));
    }

    @Test
    void resolvingAlreadyResolvedIncidentFails() {
        IncidentJpaEntity entity = activeIncident();
        entity.setStatus(IncidentStatus.RESOLVED);
        entity.setResolvedBy(1L);
        entity.setResolvedAt(System.currentTimeMillis());

        when(incidentRepository.findById(50L))
                .thenReturn(Optional.of(entity));

        IllegalArgumentException exception =
                assertThrows(
                        IllegalArgumentException.class,
                        () -> service.resolveIncident(
                                50L,
                                jwtFor(1L)
                        )
                );

        assertEquals(
                "Incident is already resolved",
                exception.getMessage()
        );
    }

    private IncidentJpaEntity activeIncident() {
        IncidentJpaEntity entity = new IncidentJpaEntity();

        entity.setId(50L);
        entity.setType(
                IncidentType.VEHICLE_BREAKDOWN
        );
        entity.setDescription("Flat tire");
        entity.setStatus(IncidentStatus.ACTIVE);
        entity.setJourneyImpact(
                JourneyImpact.DELAYED
        );
        entity.setCreatedBy(2L);
        entity.setCreatedAt(
                System.currentTimeMillis()
        );
        entity.setAffectedBusIds(Set.of());
        entity.setAffectedChildIds(Set.of());
        entity.setRelatedTrackingIds(Set.of());

        return entity;
    }

    private User user(
            Long id,
            UserRole role
    ) {
        User user = new User();
        user.setId(id);
        user.setRole(role);
        return user;
    }

    private Jwt jwtFor(Long userId) {
        Instant now = Instant.now();

        return new Jwt(
                "test-token",
                now,
                now.plusSeconds(3600),
                Map.of("alg", "none"),
                Map.of(
                        "sub", userId.toString(),
                        "user_id", userId,
                        "roles", List.of("ADMIN")
                )
        );
    }
}