package com.login.LoginBus.students.api;

import com.login.LoginBus.students.api.AssignChildrenToStopRequest;
import com.login.LoginBus.students.api.DriverChildSummaryDto;
import com.login.LoginBus.students.app.DriverChildrenService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/v1/me/bus/children")
@CrossOrigin(origins = "*")
public class DriverChildrenController {

    private final DriverChildrenService driverChildrenService;

    public DriverChildrenController(DriverChildrenService driverChildrenService) {
        this.driverChildrenService = driverChildrenService;
    }

    /** GET /api/v1/me/bus/children — list all children on the driver's bus */
    @GetMapping
    public ResponseEntity<List<DriverChildSummaryDto>> getBusChildren(@AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(driverChildrenService.getBusChildren(jwt));
    }

    /** GET /api/v1/me/bus/children/{childId} — get details of a specific child */
    @GetMapping("/{childId}")
    public ResponseEntity<DriverChildSummaryDto> getChild(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable String childId) {
        return ResponseEntity.ok(driverChildrenService.getChild(jwt, childId));
    }

    /** GET /api/v1/me/bus/children/absent?date=yyyy-MM-dd&journey=MORNING|RETURN */
    @GetMapping("/absent")
    public ResponseEntity<List<DriverChildSummaryDto>> getAbsentChildren(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam(defaultValue = "MORNING") String journey) {
        return ResponseEntity.ok(driverChildrenService.getAbsentChildren(jwt, date, journey));
    }

    /** GET /api/v1/me/bus/children/present?date=yyyy-MM-dd&journey=MORNING|RETURN */
    @GetMapping("/present")
    public ResponseEntity<List<DriverChildSummaryDto>> getPresentChildren(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam(defaultValue = "MORNING") String journey) {
        return ResponseEntity.ok(driverChildrenService.getPresentChildren(jwt, date, journey));
    }

    /** PATCH /api/v1/me/bus/children/assign-to-stop/{stopId} — assign children to a stop */
    @PatchMapping("/assign-to-stop/{stopId}")
    public ResponseEntity<Void> assignChildrenToStop(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long stopId,
            @RequestBody AssignChildrenToStopRequest request) {
        driverChildrenService.assignChildrenToStop(jwt, stopId, request);
        return ResponseEntity.noContent().build();
    }
}
