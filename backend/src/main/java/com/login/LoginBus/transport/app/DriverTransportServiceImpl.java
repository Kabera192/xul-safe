package com.login.LoginBus.transport.app;

import com.login.LoginBus.accounts.infra.ConductorJpaEntity;
import com.login.LoginBus.accounts.infra.ConductorRepository;
import com.login.LoginBus.transport.api.dto.*;
import com.login.LoginBus.transport.infra.*;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class DriverTransportServiceImpl implements DriverTransportService {

    private final ConductorRepository conductorRepository;
    private final BusRepository busRepository;
    private final RouteRepository routeRepository;
    private final StopRepository stopRepository;

    public DriverTransportServiceImpl(ConductorRepository conductorRepository,
                                      BusRepository busRepository,
                                      RouteRepository routeRepository,
                                      StopRepository stopRepository) {
        this.conductorRepository = conductorRepository;
        this.busRepository = busRepository;
        this.routeRepository = routeRepository;
        this.stopRepository = stopRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public DriverBusResponse getMyBus(Jwt jwt) {
        BusJpaEntity bus = resolveDriverBus(jwt);
        return toBusResponse(bus);
    }

    @Override
    @Transactional(readOnly = true)
    public DriverRouteResponse getMyRoute(Jwt jwt) {
        BusJpaEntity bus = resolveDriverBus(jwt);
        if (bus.getRouteId() == null) throw new IllegalStateException("No route assigned to your bus");
        RouteJpaEntity route = routeRepository.findById(bus.getRouteId())
                .orElseThrow(() -> new IllegalStateException("Route not found"));
        return toRouteResponse(route);
    }

    @Override
    @Transactional(readOnly = true)
    public List<StopResponse> getMyStops(Jwt jwt) {
        BusJpaEntity bus = resolveDriverBus(jwt);
        if (bus.getRouteId() == null) return List.of();
        return stopRepository.findByRouteIdOrderByOrderIndexAsc(bus.getRouteId())
                .stream().map(this::toStopResponse).toList();
    }

    @Override
    @Transactional
    public StopResponse addStop(Jwt jwt, CreateStopRequest request) {
        if (request.getName() == null || request.getName().isBlank())
            throw new IllegalArgumentException("Stop name is required");

        BusJpaEntity bus = resolveDriverBus(jwt);
        if (bus.getRouteId() == null) throw new IllegalStateException("No route assigned to your bus");

        StopJpaEntity stop = new StopJpaEntity();
        stop.setRouteId(bus.getRouteId());
        stop.setName(request.getName().trim());
        stop.setLatitude(request.getLatitude());
        stop.setLongitude(request.getLongitude());
        stop.setOrderIndex(request.getOrderIndex());
        stop = stopRepository.save(stop);
        return toStopResponse(stop);
    }

    @Override
    @Transactional
    public StopResponse updateStop(Jwt jwt, Long stopId, UpdateStopRequest request) {
        BusJpaEntity bus = resolveDriverBus(jwt);
        StopJpaEntity stop = stopRepository.findById(stopId)
                .orElseThrow(() -> new IllegalArgumentException("Stop not found"));
        if (!stop.getRouteId().equals(bus.getRouteId())) {
            throw new IllegalStateException("Stop does not belong to your route");
        }

        if (request.getName() != null && !request.getName().isBlank())
            stop.setName(request.getName().trim());
        if (request.getLatitude() != null) stop.setLatitude(request.getLatitude());
        if (request.getLongitude() != null) stop.setLongitude(request.getLongitude());
        if (request.getOrderIndex() != null) stop.setOrderIndex(request.getOrderIndex());

        stop = stopRepository.save(stop);
        return toStopResponse(stop);
    }

    @Override
    @Transactional
    public void deleteStop(Jwt jwt, Long stopId) {
        BusJpaEntity bus = resolveDriverBus(jwt);
        StopJpaEntity stop = stopRepository.findById(stopId)
                .orElseThrow(() -> new IllegalArgumentException("Stop not found"));
        if (!stop.getRouteId().equals(bus.getRouteId())) {
            throw new IllegalStateException("Stop does not belong to your route");
        }
        stopRepository.delete(stop);
    }

    // ── helpers ──────────────────────────────────────────────────────────────

    private BusJpaEntity resolveDriverBus(Jwt jwt) {
        Long userId = jwt.getClaim("user_id");
        if (userId == null) throw new IllegalArgumentException("Invalid token");

        ConductorJpaEntity conductor = conductorRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalStateException("Conductor profile not found for your account"));

        return busRepository.findByConductorId(conductor.getId())
                .orElseThrow(() -> new IllegalStateException("No bus assigned to you"));
    }

    private DriverBusResponse toBusResponse(BusJpaEntity bus) {
        return new DriverBusResponse(
                bus.getId(),
                bus.getPlateNumber(),
                bus.getModel(),
                bus.getCapacity(),
                bus.getStatus() != null ? bus.getStatus().name() : null,
                bus.getRouteId(),
                bus.getPhotoUrl()
        );
    }

    private DriverRouteResponse toRouteResponse(RouteJpaEntity route) {
        return new DriverRouteResponse(
                route.getId(),
                route.getName(),
                route.getDescription(),
                route.getStartLocation(),
                route.getEndLocation()
        );
    }

    private StopResponse toStopResponse(StopJpaEntity stop) {
        return new StopResponse(
                stop.getId(),
                stop.getRouteId(),
                stop.getName(),       // mapped to locationName in StopResponse
                stop.getLatitude(),   // mapped to locationLat in StopResponse
                stop.getLongitude(),  // mapped to locationLong in StopResponse
                stop.getOrderIndex()
        );
    }
}
