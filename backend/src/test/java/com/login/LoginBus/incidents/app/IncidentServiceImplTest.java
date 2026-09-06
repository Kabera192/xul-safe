package com.login.LoginBus.incidents.app;

import com.login.LoginBus.accounts.app.AccountsPublicService;
import com.login.LoginBus.accounts.domain.User;
import com.login.LoginBus.accounts.domain.UserRole;
import com.login.LoginBus.incidents.api.dto.CreateIncidentRequest;
import com.login.LoginBus.incidents.domain.Incident;
import com.login.LoginBus.incidents.domain.IncidentStatus;
import com.login.LoginBus.incidents.domain.IncidentType;
import com.login.LoginBus.incidents.domain.JourneyImpact;
import com.login.LoginBus.incidents.infra.IncidentJpaEntity;
import com.login.LoginBus.incidents.infra.IncidentRepository;
import com.login.LoginBus.notifications.app.NotificationsPublicService;
import com.login.LoginBus.students.app.StudentsPublicService;
import com.login.LoginBus.transport.app.TransportPublicService;
import com.login.LoginBus.transport.domain.Bus;
import com.login.LoginBus.transport.domain.BusStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.Jwt;

import java.time.Instant;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class IncidentServiceImplTest {

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
    }

    @Test
    void adminCanCreateGeneralIncident() {
        Jwt jwt = jwtFor(10L);

        when(accountsService.getUserById(10L))
                .thenReturn(user(10L, UserRole.ADMIN));

        when(incidentRepository.save(any(IncidentJpaEntity.class)))
                .thenAnswer(invocation -> {
                    IncidentJpaEntity entity = invocation.getArgument(0);
                    entity.setId(100L);
                    return entity;
                });

        CreateIncidentRequest request = new CreateIncidentRequest();
        request.setType(IncidentType.ROAD_OBSTRUCTION);
        request.setDescription("Main road is blocked");
        request.setJourneyImpact(JourneyImpact.DELAYED);

        Incident created = service.createIncident(jwt, request);

        assertEquals(100L, created.getId());
        assertEquals(IncidentStatus.ACTIVE, created.getStatus());
        assertEquals(10L, created.getCreatedBy());
        assertEquals(IncidentType.ROAD_OBSTRUCTION, created.getType());
        assertEquals(JourneyImpact.DELAYED, created.getJourneyImpact());
        assertTrue(created.getAffectedBusIds().isEmpty());
        assertTrue(created.getAffectedChildIds().isEmpty());
        assertNotNull(created.getCreatedAt());
    }

    @Test
    void parentCannotCreateIncident() {
        Jwt jwt = jwtFor(20L);

        when(accountsService.getUserById(20L))
                .thenReturn(user(20L, UserRole.PARENT));

        CreateIncidentRequest request = new CreateIncidentRequest();
        request.setType(IncidentType.MEDICAL);
        request.setDescription("Child became sick");
        request.setJourneyImpact(JourneyImpact.NONE);

        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> service.createIncident(jwt, request)
        );

        assertEquals(
                "Only ADMIN, DRIVER, or CONDUCTOR users can manage incidents",
                exception.getMessage()
        );

        verify(incidentRepository, never())
                .save(any(IncidentJpaEntity.class));
    }

    @Test
    void driverCannotTargetAnotherBus() {
        Jwt jwt = jwtFor(30L);

        when(accountsService.getUserById(30L))
                .thenReturn(user(30L, UserRole.DRIVER));

        Bus assignedBus = new Bus();
        assignedBus.setId(12L);
        assignedBus.setStatus(BusStatus.ACTIVE);

        when(transportService.getAssignedBusForUser(30L))
                .thenReturn(assignedBus);

        Bus otherBus = new Bus();
        otherBus.setId(99L);

        when(transportService.getBusById(99L))
                .thenReturn(otherBus);

        CreateIncidentRequest request = new CreateIncidentRequest();
        request.setType(IncidentType.VEHICLE_BREAKDOWN);
        request.setDescription("Bus problem");
        request.setJourneyImpact(JourneyImpact.STOPPED);
        request.setAffectedBusIds(Set.of(99L));

        IllegalArgumentException exception = assertThrows(
                IllegalArgumentException.class,
                () -> service.createIncident(jwt, request)
        );

        assertEquals(
                "Transport users can only manage incidents for their assigned bus",
                exception.getMessage()
        );
    }

    @Test
    void duplicateAffectedBusIdsAreCollapsed() {
        Jwt jwt = jwtFor(40L);

        when(accountsService.getUserById(40L))
                .thenReturn(user(40L, UserRole.ADMIN));

        Bus bus = new Bus();
        bus.setId(12L);

        when(transportService.getBusById(12L))
                .thenReturn(bus);

        when(incidentRepository.save(any(IncidentJpaEntity.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        Set<Long> buses = new HashSet<>();
        buses.add(12L);
        buses.add(12L);

        CreateIncidentRequest request = new CreateIncidentRequest();
        request.setType(IncidentType.VEHICLE_BREAKDOWN);
        request.setDescription("Flat tire");
        request.setJourneyImpact(JourneyImpact.DELAYED);
        request.setAffectedBusIds(buses);

        Incident created = service.createIncident(jwt, request);

        assertEquals(1, created.getAffectedBusIds().size());
        assertTrue(created.getAffectedBusIds().contains(12L));
    }

    private User user(Long id, UserRole role) {
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