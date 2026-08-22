package com.login.LoginBus.transport.app;

import com.login.LoginBus.accounts.infra.ConductorJpaEntity;
import com.login.LoginBus.accounts.infra.ConductorRepository;
import com.login.LoginBus.students.infra.ChildJpaEntity;
import com.login.LoginBus.students.infra.ChildRepository;
import com.login.LoginBus.transport.api.dto.*;
import com.login.LoginBus.transport.infra.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class DriverTransportServiceImpl implements DriverTransportService {

    private static final Logger log = LoggerFactory.getLogger(DriverTransportServiceImpl.class);

    private final ConductorRepository conductorRepository;
    private final BusRepository busRepository;
    private final RouteRepository routeRepository;
    private final BusStopRepository busStopRepository;
    private final ChildRepository childRepository;

    public DriverTransportServiceImpl(ConductorRepository conductorRepository,
                                      BusRepository busRepository,
                                      RouteRepository routeRepository,
                                      BusStopRepository busStopRepository,
                                      ChildRepository childRepository) {
        this.conductorRepository = conductorRepository;
        this.busRepository = busRepository;
        this.routeRepository = routeRepository;
        this.busStopRepository = busStopRepository;
        this.childRepository = childRepository;
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
        return busStopRepository.findByRouteIdOrderByStopOrderAsc(bus.getRouteId())
                .stream().map(this::toStopResponse).toList();
    }

    @Override
    @Transactional
    public StopResponse addStop(Jwt jwt, CreateStopRequest request) {
        if (request.getName() == null || request.getName().isBlank())
            throw new IllegalArgumentException("Stop name is required");

        BusJpaEntity bus = resolveDriverBus(jwt);
        if (bus.getRouteId() == null) throw new IllegalStateException("No route assigned to your bus");

        BusStopJpaEntity stop = new BusStopJpaEntity();
        stop.setRouteId(bus.getRouteId());
        stop.setName(request.getName().trim());
        stop.setLatitude(request.getLatitude());
        stop.setLongitude(request.getLongitude());
        stop.setAddress("");
        // Callers (the driver app doesn't) may omit an explicit order — default
        // to appending after the last stop on the route instead of leaving it
        // null, which would make the new stop sort unpredictably.
        stop.setStopOrder(request.getOrderIndex() != null
                ? request.getOrderIndex()
                : nextStopOrder(bus.getRouteId()));
        stop = busStopRepository.save(stop);
        return toStopResponse(stop);
    }

    private int nextStopOrder(Long routeId) {
        return busStopRepository.findByRouteIdOrderByStopOrderAsc(routeId).stream()
                .mapToInt(s -> s.getStopOrder() != null ? s.getStopOrder() : 0)
                .max().orElse(-1) + 1;
    }

    @Override
    @Transactional
    public StopResponse updateStop(Jwt jwt, String stopId, UpdateStopRequest request) {
        BusJpaEntity bus = resolveDriverBus(jwt);
        BusStopJpaEntity stop = busStopRepository.findById(stopId)
                .orElseThrow(() -> new IllegalArgumentException("Stop not found"));
        if (!stop.getRouteId().equals(bus.getRouteId())) {
            throw new IllegalStateException("Stop does not belong to your route");
        }

        if (request.getName() != null && !request.getName().isBlank())
            stop.setName(request.getName().trim());
        if (request.getLatitude() != null) stop.setLatitude(request.getLatitude());
        if (request.getLongitude() != null) stop.setLongitude(request.getLongitude());
        if (request.getOrderIndex() != null) stop.setStopOrder(request.getOrderIndex());

        stop = busStopRepository.save(stop);
        return toStopResponse(stop);
    }

    @Override
    @Transactional
    public void deleteStop(Jwt jwt, String stopId, String reason) {
        BusJpaEntity bus = resolveDriverBus(jwt);
        BusStopJpaEntity stop = busStopRepository.findById(stopId)
                .orElseThrow(() -> new IllegalArgumentException("Stop not found"));
        if (!stop.getRouteId().equals(bus.getRouteId())) {
            throw new IllegalStateException("Stop does not belong to your route");
        }
        if (reason != null && !reason.isBlank()) {
            log.info("Bus stop {} ('{}') deleted by conductor on bus {}, reason: {}",
                    stopId, stop.getName(), bus.getId(), reason.trim());
        }
        List<ChildJpaEntity> affected = childRepository.findByAnyStopReference(stopId);
        for (ChildJpaEntity child : affected) {
            if (stopId.equals(child.getBusStopId())) child.setBusStopId(null);
        }
        childRepository.saveAll(affected);
        busStopRepository.delete(stop);
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

    private StopResponse toStopResponse(BusStopJpaEntity stop) {
        return new StopResponse(
                stop.getId(),
                stop.getRouteId(),
                stop.getName(),
                stop.getLatitude(),
                stop.getLongitude(),
                stop.getStopOrder()
        );
    }
}
