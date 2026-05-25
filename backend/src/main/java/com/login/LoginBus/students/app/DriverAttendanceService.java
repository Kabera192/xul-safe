package com.login.LoginBus.students.app;

import com.login.LoginBus.students.api.AttendanceWithChildDto;
import com.login.LoginBus.students.api.MarkAttendanceRequest;
import org.springframework.security.oauth2.jwt.Jwt;

import java.time.LocalDate;
import java.util.List;

public interface DriverAttendanceService {

    /**
     * Returns all children on the driver's bus with their two-step attendance
     * status (boarded + droppedOff) for the given date and session.
     * Children with no record yet are returned with boarded=false, droppedOff=false.
     */
    List<AttendanceWithChildDto> getSessionAttendance(Jwt jwt, LocalDate date, String session);

    /**
     * Marks a single attendance event (BOARDED or DROPPED_OFF) for a child.
     * Automatically sends a push notification to the child's parent.
     * Returns the updated full record.
     */
    AttendanceWithChildDto markAttendance(Jwt jwt, MarkAttendanceRequest request);
}

