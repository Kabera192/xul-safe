package com.login.LoginBus.transport.app;

import com.login.LoginBus.transport.api.dto.*;
import org.springframework.security.oauth2.jwt.Jwt;

import java.util.List;

public interface DriverTransportService {
    DriverBusResponse getMyBus(Jwt jwt);
    DriverRouteResponse getMyRoute(Jwt jwt);
    List<StopResponse> getMyStops(Jwt jwt);
    StopResponse addStop(Jwt jwt, CreateStopRequest request);
    StopResponse updateStop(Jwt jwt, String stopId, UpdateStopRequest request);
    void deleteStop(Jwt jwt, String stopId, String reason);
}
