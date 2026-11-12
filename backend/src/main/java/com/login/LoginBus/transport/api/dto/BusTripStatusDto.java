package com.login.LoginBus.transport.api.dto;

/**
 * Today's trip status for one bus, derived from its most recent
 * BusTracking record (if any) updated since midnight.
 */
public class BusTripStatusDto {

    private Long busId;
    private String status; // SCHEDULED | IN_PROGRESS | COMPLETED

    public BusTripStatusDto() {}

    public BusTripStatusDto(Long busId, String status) {
        this.busId = busId;
        this.status = status;
    }

    public Long getBusId() { return busId; }
    public void setBusId(Long busId) { this.busId = busId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
