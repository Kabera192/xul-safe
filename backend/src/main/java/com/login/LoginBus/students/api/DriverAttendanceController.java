package com.login.LoginBus.students.api;

import com.login.LoginBus.students.app.DriverAttendanceService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * REST controller for driver-confirmed attendance.
 *
 * GET  /api/v1/me/bus/attendance?date=yyyy-MM-dd&session=MORNING|AFTERNOON
 *      Returns every child on the driver's bus with their confirmed status.
 *
 * POST /api/v1/me/bus/attendance/mark
 *      Upserts a single attendance record (toggle boarding / drop-off check).
 */
@RestController
@RequestMapping("/api/v1/me/bus/attendance")
@CrossOrigin(origins = "*")
public class DriverAttendanceController {

    private final DriverAttendanceService driverAttendanceService;

    public DriverAttendanceController(DriverAttendanceService driverAttendanceService) {
        this.driverAttendanceService = driverAttendanceService;
    }

    /**
     * GET /api/v1/me/bus/attendance?date=yyyy-MM-dd&session=MORNING|AFTERNOON
     */
    @GetMapping
    public ResponseEntity<List<AttendanceWithChildDto>> getSessionAttendance(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam(defaultValue = "MORNING") String session) {

        return ResponseEntity.ok(
                driverAttendanceService.getSessionAttendance(jwt, date, session));
    }

    /**
     * POST /api/v1/me/bus/attendance/mark
     * Body: { "childId": "...", "date": "yyyy-MM-dd", "session": "MORNING|AFTERNOON", "confirmed": true }
     */
    @PostMapping("/mark")
    public ResponseEntity<AttendanceWithChildDto> markAttendance(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody MarkAttendanceRequest request) {

        return ResponseEntity.ok(
                driverAttendanceService.markAttendance(jwt, request));
    }
}
