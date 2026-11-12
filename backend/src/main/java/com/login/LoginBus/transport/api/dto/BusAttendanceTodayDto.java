package com.login.LoginBus.transport.api.dto;

/**
 * Today's attendance summary for one bus — everything the admin dashboard's
 * "Bus attendance" table needs in a single row, scoped to today only.
 */
public class BusAttendanceTodayDto {

    private Long busId;
    private String plateNumber;
    private String routeName;
    private String date; // ISO yyyy-MM-dd — the server's "today", not the client's clock

    /** Null while the trip hasn't started (tripStatus == SCHEDULED) — no one could truthfully be marked present or absent yet. */
    private Integer present;
    private Integer absent;
    private String tripStatus; // SCHEDULED | IN_PROGRESS | COMPLETED

    public BusAttendanceTodayDto() {}

    public BusAttendanceTodayDto(Long busId, String plateNumber, String routeName, String date,
                                  Integer present, Integer absent, String tripStatus) {
        this.busId = busId;
        this.plateNumber = plateNumber;
        this.routeName = routeName;
        this.date = date;
        this.present = present;
        this.absent = absent;
        this.tripStatus = tripStatus;
    }

    public Long getBusId() { return busId; }
    public void setBusId(Long busId) { this.busId = busId; }
    public String getPlateNumber() { return plateNumber; }
    public void setPlateNumber(String plateNumber) { this.plateNumber = plateNumber; }
    public String getRouteName() { return routeName; }
    public void setRouteName(String routeName) { this.routeName = routeName; }
    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    public Integer getPresent() { return present; }
    public void setPresent(Integer present) { this.present = present; }
    public Integer getAbsent() { return absent; }
    public void setAbsent(Integer absent) { this.absent = absent; }
    public String getTripStatus() { return tripStatus; }
    public void setTripStatus(String tripStatus) { this.tripStatus = tripStatus; }
}
