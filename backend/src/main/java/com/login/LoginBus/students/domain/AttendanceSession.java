package com.login.LoginBus.students.domain;

/**
 * Represents which part of the day the attendance is for.
 * MORNING  – driver confirms the child boarded the bus in the morning.
 * AFTERNOON – driver confirms the child was dropped off in the afternoon.
 */
public enum AttendanceSession {
    MORNING,
    AFTERNOON
}
