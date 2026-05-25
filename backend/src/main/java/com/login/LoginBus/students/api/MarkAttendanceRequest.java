package com.login.LoginBus.students.api;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.LocalDate;

/**
 * Request body for the mark-attendance endpoint.
 *
 * Example JSON:
 * {
 *   "childId": "child-uuid-123",
 *   "date": "2026-05-15",
 *   "session": "MORNING",
 *   "action": "BOARDED",
 *   "confirmed": true
 * }
 *
 * action values:
 *   BOARDED     – child got on the bus
 *   DROPPED_OFF – child arrived at destination (school for MORNING, stop for AFTERNOON)
 */
public class MarkAttendanceRequest {

    @JsonProperty("childId")
    private String childId;

    @JsonFormat(pattern = "yyyy-MM-dd")
    @JsonProperty("date")
    private LocalDate date;

    /** "MORNING" or "AFTERNOON" */
    @JsonProperty("session")
    private String session;

    /** "BOARDED" or "DROPPED_OFF" */
    @JsonProperty("action")
    private String action;

    /** true = mark; false = unmark */
    @JsonProperty("confirmed")
    private boolean confirmed;

    public MarkAttendanceRequest() {}

    public String getChildId() { return childId; }
    public void setChildId(String childId) { this.childId = childId; }

    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }

    public String getSession() { return session; }
    public void setSession(String session) { this.session = session; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public boolean isConfirmed() { return confirmed; }
    public void setConfirmed(boolean confirmed) { this.confirmed = confirmed; }
}

