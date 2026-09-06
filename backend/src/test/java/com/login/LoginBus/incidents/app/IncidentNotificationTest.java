package com.login.LoginBus.incidents.app;

import com.login.LoginBus.accounts.app.AccountsPublicService;
import com.login.LoginBus.accounts.domain.User;
import com.login.LoginBus.accounts.domain.UserRole;
import com.login.LoginBus.incidents.api.dto.CreateIncidentRequest;
import com.login.LoginBus.incidents.domain.IncidentType;
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
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.security.oauth2.jwt.Jwt;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class IncidentNotificationTest {

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

        when(incidentRepository.save(any(IncidentJpaEntity.class)))
                .thenAnswer(invocation -> {
                    IncidentJpaEntity entity = invocation.getArgument(0);
                    entity.setId(100L);
                    return entity;
                });
    }

    @Test
    void childOnlyIncidentNotifiesOnlyAffectedChildParentsAndAdmins() {
        Child timmy = child("timmy", 101L, 12L);
        Child bob = child("bob", 102L, 12L);

        when(studentsService.childExists("timmy")).thenReturn(true);
        when(studentsService.childExists("bob")).thenReturn(true);

        when(studentsService.getChildById("timmy")).thenReturn(timmy);
        when(studentsService.getChildById("bob")).thenReturn(bob);

        Bus bus = new Bus();
        bus.setId(12L);

        when(transportService.getBusById(12L))
                .thenReturn(bus);

        User admin = user(900L, UserRole.ADMIN);

        when(accountsService.getUsersByRole(UserRole.ADMIN))
                .thenReturn(List.of(admin));

        CreateIncidentRequest request = new CreateIncidentRequest();
        request.setType(IncidentType.CHILD_BEHAVIOR);
        request.setDescription("Timmy and Bob were involved in a fight");
        request.setJourneyImpact(JourneyImpact.NONE);
        request.setAffectedBusIds(Set.of(12L));
        request.setAffectedChildIds(Set.of("timmy", "bob"));

        service.createIncident(jwtFor(1L), request);

        ArgumentCaptor<List<Long>> recipientsCaptor =
                ArgumentCaptor.forClass(List.class);

        verify(notificationsService).sendNotificationToUsers(
                recipientsCaptor.capture(),
                eq(1L),
                eq(NotificationType.INFO),
                eq(NotificationCategory.INCIDENT_REPORTED),
                eq("Incident reported"),
                eq("Timmy and Bob were involved in a fight")
        );

        assertEquals(
                Set.of(101L, 102L, 900L),
                Set.copyOf(recipientsCaptor.getValue())
        );

        verify(studentsService, never())
                .getChildrenForBus(12L);
    }

    @Test
    void busWideIncidentNotifiesBusParentsAndAdmins() {
        Child child1 = child("child-1", 101L, 12L);
        Child child2 = child("child-2", 102L, 12L);

        Bus bus = new Bus();
        bus.setId(12L);

        when(transportService.getBusById(12L))
                .thenReturn(bus);

        when(studentsService.getChildrenForBus(12L))
                .thenReturn(List.of(child1, child2));

        User admin = user(900L, UserRole.ADMIN);

        when(accountsService.getUsersByRole(UserRole.ADMIN))
                .thenReturn(List.of(admin));

        CreateIncidentRequest request = new CreateIncidentRequest();
        request.setType(IncidentType.VEHICLE_BREAKDOWN);
        request.setDescription("Rear tire punctured");
        request.setJourneyImpact(JourneyImpact.DELAYED);
        request.setAffectedBusIds(Set.of(12L));

        service.createIncident(jwtFor(1L), request);

        ArgumentCaptor<List<Long>> recipientsCaptor =
                ArgumentCaptor.forClass(List.class);

        verify(notificationsService).sendNotificationToUsers(
                recipientsCaptor.capture(),
                eq(1L),
                eq(NotificationType.WARNING),
                eq(NotificationCategory.INCIDENT_REPORTED),
                eq("Incident reported"),
                eq("Rear tire punctured")
        );

        assertEquals(
                Set.of(101L, 102L, 900L),
                Set.copyOf(recipientsCaptor.getValue())
        );
    }

    @Test
    void duplicateRecipientsAreSentOnlyOnce() {
        Child child1 = child("child-1", 101L, 12L);
        Child child2 = child("child-2", 101L, 12L);

        User admin = user(101L, UserRole.ADMIN);

        Bus bus = new Bus();
        bus.setId(12L);

        when(transportService.getBusById(12L))
                .thenReturn(bus);

        when(studentsService.getChildrenForBus(12L))
                .thenReturn(List.of(child1, child2));

        when(accountsService.getUsersByRole(UserRole.ADMIN))
                .thenReturn(List.of(admin));

        CreateIncidentRequest request = new CreateIncidentRequest();
        request.setType(IncidentType.DELAY);
        request.setDescription("Heavy traffic");
        request.setJourneyImpact(JourneyImpact.DELAYED);
        request.setAffectedBusIds(Set.of(12L));

        service.createIncident(jwtFor(1L), request);

        ArgumentCaptor<List<Long>> recipientsCaptor =
                ArgumentCaptor.forClass(List.class);

        verify(notificationsService).sendNotificationToUsers(
                recipientsCaptor.capture(),
                anyLong(),
                any(),
                any(),
                anyString(),
                anyString()
        );

        List<Long> recipients = recipientsCaptor.getValue();

        assertEquals(1, recipients.size());
        assertEquals(101L, recipients.get(0));
    }

    @Test
    void childIncidentThatStopsJourneySplitsDetailedAndOperationalNotifications() {
        Child timmy = child("timmy", 101L, 12L);
        Child otherChild = child("other", 103L, 12L);

        when(studentsService.childExists("timmy"))
                .thenReturn(true);

        when(studentsService.getChildById("timmy"))
                .thenReturn(timmy);

        Bus bus = new Bus();
        bus.setId(12L);

        when(transportService.getBusById(12L))
                .thenReturn(bus);

        when(studentsService.getChildrenForBus(12L))
                .thenReturn(List.of(timmy, otherChild));

        User admin = user(900L, UserRole.ADMIN);

        when(accountsService.getUsersByRole(UserRole.ADMIN))
                .thenReturn(List.of(admin));

        CreateIncidentRequest request = new CreateIncidentRequest();
        request.setType(IncidentType.MEDICAL);
        request.setDescription("Timmy experienced a medical emergency");
        request.setJourneyImpact(JourneyImpact.STOPPED);
        request.setAffectedBusIds(Set.of(12L));
        request.setAffectedChildIds(Set.of("timmy"));

        service.createIncident(jwtFor(1L), request);

        ArgumentCaptor<List<Long>> recipientsCaptor =
                ArgumentCaptor.forClass(List.class);

        ArgumentCaptor<String> titleCaptor =
                ArgumentCaptor.forClass(String.class);

        ArgumentCaptor<String> messageCaptor =
                ArgumentCaptor.forClass(String.class);

        verify(notificationsService, times(2))
                .sendNotificationToUsers(
                        recipientsCaptor.capture(),
                        eq(1L),
                        eq(NotificationType.URGENT),
                        eq(NotificationCategory.INCIDENT_REPORTED),
                        titleCaptor.capture(),
                        messageCaptor.capture()
                );

        List<List<Long>> recipientCalls =
                recipientsCaptor.getAllValues();

        List<String> titleCalls =
                titleCaptor.getAllValues();

        List<String> messageCalls =
                messageCaptor.getAllValues();

        int detailedIndex =
                titleCalls.indexOf("Incident reported");

        int operationalIndex =
                titleCalls.indexOf("Journey affected by incident");

        assertTrue(detailedIndex >= 0);
        assertTrue(operationalIndex >= 0);

        assertEquals(
                Set.of(101L, 900L),
                Set.copyOf(recipientCalls.get(detailedIndex))
        );

        assertEquals(
                "Timmy experienced a medical emergency",
                messageCalls.get(detailedIndex)
        );

        assertEquals(
                Set.of(103L),
                Set.copyOf(recipientCalls.get(operationalIndex))
        );

        assertEquals(
                "The bus journey has been stopped due to an active incident.",
                messageCalls.get(operationalIndex)
        );

        assertFalse(
                messageCalls.get(operationalIndex)
                        .contains("Timmy")
        );
    }

    private Child child(
            String id,
            Long parentId,
            Long busId
    ) {
        Child child = new Child();
        child.setId(id);
        child.setParentId(parentId);
        child.setBusId(busId);
        return child;
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