package com.login.LoginBus.incidents.app;

import com.login.LoginBus.accounts.app.AccountsPublicService;
import com.login.LoginBus.accounts.domain.User;
import com.login.LoginBus.accounts.domain.UserRole;
import com.login.LoginBus.incidents.api.dto.CreateIncidentRequest;
import com.login.LoginBus.incidents.domain.Incident;
import com.login.LoginBus.incidents.domain.IncidentType;
import com.login.LoginBus.incidents.domain.JourneyImpact;
import com.login.LoginBus.incidents.infra.IncidentJpaEntity;
import com.login.LoginBus.incidents.infra.IncidentRepository;
import com.login.LoginBus.notifications.app.NotificationsPublicService;
import com.login.LoginBus.students.app.StudentsPublicService;
import com.login.LoginBus.students.domain.Child;
import com.login.LoginBus.transport.app.TransportPublicService;
import com.login.LoginBus.transport.domain.Bus;
import com.login.LoginBus.transport.domain.BusTracking;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.Jwt;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class IncidentTransportRulesTest {

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

        when(accountsService.getUsersByRole(UserRole.ADMIN))
                .thenReturn(List.of());

        when(incidentRepository.save(any(IncidentJpaEntity.class)))
                .thenAnswer(invocation -> {
                    IncidentJpaEntity entity = invocation.getArgument(0);
                    entity.setId(100L);
                    return entity;
                });
    }

    @Test
    void driverCannotReportIncidentForChildOnAnotherBus() {
        when(accountsService.getUserById(30L))
                .thenReturn(user(30L, UserRole.DRIVER));

        Bus assignedBus = new Bus();
        assignedBus.setId(12L);

        when(transportService.getAssignedBusForUser(30L))
                .thenReturn(assignedBus);

        Child child = new Child();
        child.setId("child-99");
        child.setBusId(99L);

        when(studentsService.childExists("child-99"))
                .thenReturn(true);

        when(studentsService.getChildById("child-99"))
                .thenReturn(child);

        CreateIncidentRequest request = new CreateIncidentRequest();
        request.setType(IncidentType.MEDICAL);
        request.setDescription("Child became sick");
        request.setJourneyImpact(JourneyImpact.NONE);
        request.setAffectedChildIds(Set.of("child-99"));

        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> service.createIncident(jwtFor(30L), request)
        );

        assertEquals(
                "Transport users can only manage incidents involving children assigned to their bus",
                exception.getMessage()
        );

        verify(incidentRepository, never())
                .save(any(IncidentJpaEntity.class));
    }

    @Test
    void activeTrackingForAffectedBusIsCapturedAtCreation() {
        when(accountsService.getUserById(1L))
                .thenReturn(user(1L, UserRole.ADMIN));

        Bus bus = new Bus();
        bus.setId(12L);

        when(transportService.getBusById(12L))
                .thenReturn(bus);

        BusTracking tracking = new BusTracking();
        tracking.setId("tracking-abc");
        tracking.setBusId(12L);

        when(transportService.getActiveBusTrackingForBus(12L))
                .thenReturn(tracking);

        CreateIncidentRequest request = new CreateIncidentRequest();
        request.setType(IncidentType.VEHICLE_BREAKDOWN);
        request.setDescription("Rear tire punctured");
        request.setJourneyImpact(JourneyImpact.DELAYED);
        request.setAffectedBusIds(Set.of(12L));

        Incident created =
                service.createIncident(jwtFor(1L), request);

        assertEquals(
                Set.of("tracking-abc"),
                created.getRelatedTrackingIds()
        );
    }

    @Test
    void childSpecificDriverIncidentCapturesCurrentBusTrackingWithoutMarkingBusAffected() {
        when(accountsService.getUserById(30L))
                .thenReturn(user(30L, UserRole.DRIVER));

        Bus assignedBus = new Bus();
        assignedBus.setId(12L);

        when(transportService.getAssignedBusForUser(30L))
                .thenReturn(assignedBus);

        Child child = new Child();
        child.setId("timmy");
        child.setBusId(12L);
        child.setParentId(101L);

        when(studentsService.childExists("timmy"))
                .thenReturn(true);

        when(studentsService.getChildById("timmy"))
                .thenReturn(child);

        BusTracking tracking = new BusTracking();
        tracking.setId("tracking-current");
        tracking.setBusId(12L);

        when(transportService.getActiveBusTrackingForBus(12L))
                .thenReturn(tracking);

        CreateIncidentRequest request = new CreateIncidentRequest();
        request.setType(IncidentType.MEDICAL);
        request.setDescription("Timmy became sick");
        request.setJourneyImpact(JourneyImpact.NONE);
        request.setAffectedChildIds(Set.of("timmy"));

        Incident created =
                service.createIncident(jwtFor(30L), request);

        assertTrue(created.getAffectedBusIds().isEmpty());

        assertEquals(
                Set.of("timmy"),
                created.getAffectedChildIds()
        );

        assertEquals(
                Set.of("tracking-current"),
                created.getRelatedTrackingIds()
        );
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
                        "roles", List.of("DRIVER")
                )
        );
    }
}