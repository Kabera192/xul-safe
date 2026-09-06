package com.login.LoginBus.incidents.domain;

/**
 * Lifecycle status of an incident.
 *
 * Incidents are created as ACTIVE and become RESOLVED through
 * the dedicated resolution operation.
 */
public enum IncidentStatus {
    ACTIVE,
    RESOLVED
}