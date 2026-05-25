package com.login.LoginBus.transport.api;

import com.login.LoginBus.transport.api.dto.*;
import com.login.LoginBus.transport.app.DriverTransportService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/me")
@CrossOrigin(origins = "*")
public class DriverTransportController {

    private final DriverTransportService driverTransportService;

    public DriverTransportController(DriverTransportService driverTransportService) {
        this.driverTransportService = driverTransportService;
    }

    /** GET /api/v1/me/bus — get the bus assigned to the authenticated driver */
    @GetMapping("/bus")
    public ResponseEntity<DriverBusResponse> getMyBus(@AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(driverTransportService.getMyBus(jwt));
    }

    /** GET /api/v1/me/bus/route — get the route of the driver's bus */
    @GetMapping("/bus/route")
    public ResponseEntity<DriverRouteResponse> getMyRoute(@AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(driverTransportService.getMyRoute(jwt));
    }

    /** GET /api/v1/me/bus/route/stops — list all stops on the driver's route */
    @GetMapping("/bus/route/stops")
    public ResponseEntity<List<StopResponse>> getMyStops(@AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(driverTransportService.getMyStops(jwt));
    }

    /** POST /api/v1/me/bus/route/stops — add a new stop */
    @PostMapping("/bus/route/stops")
    public ResponseEntity<StopResponse> addStop(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody CreateStopRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(driverTransportService.addStop(jwt, request));
    }

    /** PATCH /api/v1/me/bus/route/stops/{stopId} — update a stop */
    @PatchMapping("/bus/route/stops/{stopId}")
    public ResponseEntity<StopResponse> updateStop(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long stopId,
            @RequestBody UpdateStopRequest request) {
        return ResponseEntity.ok(driverTransportService.updateStop(jwt, stopId, request));
    }

    /** DELETE /api/v1/me/bus/route/stops/{stopId} — delete a stop */
    @DeleteMapping("/bus/route/stops/{stopId}")
    public ResponseEntity<Void> deleteStop(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long stopId) {
        driverTransportService.deleteStop(jwt, stopId);
        return ResponseEntity.noContent().build();
    }
}
