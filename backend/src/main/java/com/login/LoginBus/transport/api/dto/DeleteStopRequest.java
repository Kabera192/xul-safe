package com.login.LoginBus.transport.api.dto;

/**
 * Optional body for DELETE /api/v1/me/bus/route/stops/{stopId}.
 * The driver app asks for a reason before deleting a stop; it's logged
 * server-side rather than persisted anywhere.
 */
public class DeleteStopRequest {

    private String reason;

    public DeleteStopRequest() {}

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
}
