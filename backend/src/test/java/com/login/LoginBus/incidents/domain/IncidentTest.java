package com.login.LoginBus.incidents.domain;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class IncidentTest {

    @Test
    void newIncidentCanBeActive() {
        Incident incident = new Incident();
        incident.setStatus(IncidentStatus.ACTIVE);

        assertTrue(incident.isActive());
        assertFalse(incident.isResolved());
    }

    @Test
    void resolveMarksIncidentAsResolvedAndRecordsResolverAndTime() {
        Incident incident = new Incident();
        incident.setStatus(IncidentStatus.ACTIVE);

        Long resolverUserId = 42L;
        long beforeResolve = System.currentTimeMillis();

        incident.resolve(resolverUserId);

        long afterResolve = System.currentTimeMillis();

        assertEquals(IncidentStatus.RESOLVED, incident.getStatus());
        assertEquals(resolverUserId, incident.getResolvedBy());
        assertNotNull(incident.getResolvedAt());
        assertTrue(incident.getResolvedAt() >= beforeResolve);
        assertTrue(incident.getResolvedAt() <= afterResolve);
        assertTrue(incident.isResolved());
        assertFalse(incident.isActive());
    }

    @Test
    void resolvingAlreadyResolvedIncidentFails() {
        Incident incident = new Incident();
        incident.setStatus(IncidentStatus.ACTIVE);
        incident.resolve(42L);

        IllegalStateException exception = assertThrows(
                IllegalStateException.class,
                () -> incident.resolve(99L)
        );

        assertEquals(
                "Incident is already resolved",
                exception.getMessage()
        );
    }

    @Test
    void affectedIdsDoNotKeepDuplicates() {
        Incident incident = new Incident();

        incident.getAffectedBusIds().add(12L);
        incident.getAffectedBusIds().add(12L);

        incident.getAffectedChildIds().add("child-1");
        incident.getAffectedChildIds().add("child-1");

        incident.getRelatedTrackingIds().add("tracking-1");
        incident.getRelatedTrackingIds().add("tracking-1");

        assertEquals(1, incident.getAffectedBusIds().size());
        assertEquals(1, incident.getAffectedChildIds().size());
        assertEquals(1, incident.getRelatedTrackingIds().size());
    }

    @Test
    void nullCollectionsBecomeEmptyCollections() {
        Incident incident = new Incident();

        incident.setAffectedBusIds(null);
        incident.setAffectedChildIds(null);
        incident.setRelatedTrackingIds(null);

        assertNotNull(incident.getAffectedBusIds());
        assertNotNull(incident.getAffectedChildIds());
        assertNotNull(incident.getRelatedTrackingIds());

        assertTrue(incident.getAffectedBusIds().isEmpty());
        assertTrue(incident.getAffectedChildIds().isEmpty());
        assertTrue(incident.getRelatedTrackingIds().isEmpty());
    }
}