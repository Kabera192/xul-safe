package com.login.LoginBus.transport.app;

import com.login.LoginBus.accounts.app.AccountsPublicService;
import com.login.LoginBus.accounts.domain.Conductor;
import com.login.LoginBus.students.app.StudentsPublicService;
import com.login.LoginBus.students.domain.Child;
import com.login.LoginBus.students.infra.AttendanceJpaEntity;
import com.login.LoginBus.students.infra.AttendanceRepository;
import com.login.LoginBus.students.infra.ChildRepository;
import com.login.LoginBus.transport.domain.*;
import com.login.LoginBus.transport.infra.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Service implementation for Transport module.
 * Implements both TransportService and TransportPublicService.
 * Handles all business logic for buses, tracking, journeys, and routes.
 */
@Service
public class TransportServiceImpl implements TransportService, TransportPublicService {

    @Autowired
    private BusTrackingRepository busTrackingRepository;

    @Autowired
    private BusRepository busRepository;

    @Autowired
    private BusStopRepository busStopRepository;

    @Autowired
    private JourneyRepository journeyRepository;

    @Autowired
    private RouteRepository routeRepository;

    @Autowired
    private AttendanceRepository attendanceRepository;

    @Autowired
    private ChildRepository childRepository;

    @Autowired
    private RouteRequestRepository routeRequestRepository;

    // Cross-module communication via public interfaces
    @Autowired(required = false)
    private StudentsPublicService studentsService;

    @Autowired(required = false)
    private AccountsPublicService accountsService;

    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm:ss");

    // ========== Bus Tracking Operations ==========

    @Override
    public BusTracking getActiveBusTrackingForChild(String childId) {
        Optional<BusTrackingJpaEntity> entityOpt = busTrackingRepository.findActiveBusTrackingByChildId(childId);
        return entityOpt.map(BusTrackingJpaEntity::toDomain).orElse(null);
    }

    @Override
    public BusTracking getActiveBusTrackingForRoute(Long routeId) {
        Optional<BusTrackingJpaEntity> entityOpt = busTrackingRepository.findActiveBusTrackingByRouteId(routeId);
        return entityOpt.map(BusTrackingJpaEntity::toDomain).orElse(null);
    }

    @Override
    @Transactional
    public BusTracking startJourney(Map<String, Object> journeyData) {
        // Create domain entity
        BusTracking tracking = new BusTracking();

        // Set trip type and initial status
        String tripTypeStr = journeyData.get("tripType").toString();
        tracking.setTripType(TripType.valueOf(tripTypeStr));
        tracking.setStatus(BusTrackingStatus.PICKING_UP_CHILDREN);

        // Set start time
        String currentTime = LocalDateTime.now().format(TIME_FORMATTER);
        tracking.setStartTime(currentTime);

        // Set route and child
        if (journeyData.containsKey("routeId")) {
            tracking.setRouteId(Long.valueOf(journeyData.get("routeId").toString()));
        }

        if (journeyData.containsKey("childId")) {
            tracking.setChildId(journeyData.get("childId").toString());
        }

        // Set conductor ID
        if (journeyData.containsKey("conductorId")) {
            tracking.setConductorId(Long.valueOf(journeyData.get("conductorId").toString()));
        }

        // Set bus ID
        if (journeyData.containsKey("busId")) {
            tracking.setBusId(Long.valueOf(journeyData.get("busId").toString()));
        }

        // Set initial location
        if (journeyData.containsKey("latitude") && journeyData.containsKey("longitude")) {
            tracking.setCurrentLatitude(Double.valueOf(journeyData.get("latitude").toString()));
            tracking.setCurrentLongitude(Double.valueOf(journeyData.get("longitude").toString()));
        }

        // Set timestamps
        long now = System.currentTimeMillis();
        tracking.setCreatedAt(now);
        tracking.setUpdatedAt(now);

        // Convert to JPA entity and save
        BusTrackingJpaEntity entity = BusTrackingJpaEntity.fromDomain(tracking);
        BusTrackingJpaEntity saved = busTrackingRepository.save(entity);

        return saved.toDomain();
    }

    @Override
    @Transactional
    public BusTracking updateLocation(String trackingId, Double latitude, Double longitude) {
        Optional<BusTrackingJpaEntity> entityOpt = busTrackingRepository.findById(trackingId);

        if (entityOpt.isEmpty()) {
            throw new IllegalArgumentException("Bus tracking not found with ID: " + trackingId);
        }

        BusTrackingJpaEntity entity = entityOpt.get();
        entity.setCurrentLatitude(latitude);
        entity.setCurrentLongitude(longitude);

        BusTrackingJpaEntity saved = busTrackingRepository.save(entity);
        return saved.toDomain();
    }

    @Override
    @Transactional
    public BusTracking updateStatus(String trackingId, String status) {
        Optional<BusTrackingJpaEntity> entityOpt = busTrackingRepository.findById(trackingId);

        if (entityOpt.isEmpty()) {
            throw new IllegalArgumentException("Bus tracking not found with ID: " + trackingId);
        }

        BusTrackingJpaEntity entity = entityOpt.get();
        entity.setStatus(BusTrackingStatus.valueOf(status));

        BusTrackingJpaEntity saved = busTrackingRepository.save(entity);
        return saved.toDomain();
    }

    @Override
    @Transactional
    public void endJourney(String trackingId) {
        Optional<BusTrackingJpaEntity> entityOpt = busTrackingRepository.findById(trackingId);

        if (entityOpt.isEmpty()) {
            throw new IllegalArgumentException("Bus tracking not found with ID: " + trackingId);
        }

        BusTrackingJpaEntity entity = entityOpt.get();
        entity.setStatus(BusTrackingStatus.NOT_IN_ROUTE);
        busTrackingRepository.save(entity);
    }

    // ========== Route & Stop Operations ==========

    @Override
    public List<BusStop> getRouteStops(Long routeId) {
        List<BusStopJpaEntity> entities = busStopRepository.findByRouteIdOrderByStopOrderAsc(routeId);
        return entities.stream()
            .map(BusStopJpaEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    public List<BusStop> getAllBusStops() {
        List<BusStopJpaEntity> entities = busStopRepository.findAllByOrderByNameAsc();
        return entities.stream()
            .map(BusStopJpaEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    public BusStop getBusStopById(String busStopId) {
        Optional<BusStopJpaEntity> entityOpt = busStopRepository.findById(busStopId);
        return entityOpt.map(BusStopJpaEntity::toDomain).orElse(null);
    }

    @Override
    public Map<String, Object> getChildRoute(String childId) {
        Map<String, Object> details = getChildRouteDetails(childId);
        if (details.get("routeId") == null) {
            return null;
        }

        Map<String, Object> routeDetails = new HashMap<>();
        routeDetails.put("routeName", details.get("routeName"));
        routeDetails.put("routeId", details.get("routeId"));
        routeDetails.put("busStop", details.getOrDefault("assignedBusStopName", "Not assigned"));

        Map<String, Object> result = new HashMap<>();
        result.put("route", routeDetails);
        return result;
    }

    @Override
    public Map<String, Object> getChildRouteDetails(String childId) {
        if (studentsService == null) {
            throw new IllegalStateException("Students service not available");
        }

        Child child = studentsService.getChildById(childId);
        if (child == null) {
            throw new IllegalArgumentException("Child not found with ID: " + childId);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("childId", child.getId());
        result.put("childName", child.getFullName());
        result.put("availableBusStops", List.of());
        result.put("assignedBusStopName", "Not assigned");

        if (child.getBusId() == null) {
            result.put("assignmentMessage", "No bus assigned to this child");
            return result;
        }

        BusJpaEntity busEntity = busRepository.findById(child.getBusId())
            .orElseThrow(() -> new IllegalArgumentException(
                "Assigned bus not found with ID: " + child.getBusId()));

        result.put("busId", busEntity.getId());
        result.put("busPlateNumber", busEntity.getPlateNumber());

        Long routeId = busEntity.getRouteId();
        if (routeId == null) {
            result.put("assignmentMessage", "No route assigned to the child's bus");
            return result;
        }

        RouteJpaEntity routeEntity = routeRepository.findById(routeId)
            .orElseThrow(() -> new IllegalArgumentException("Route not found with ID: " + routeId));

        result.put("routeId", routeId);
        result.put(
            "routeName",
            routeEntity.getName() != null ? routeEntity.getName() : "Route " + routeId
        );

        List<BusStop> routeStops = busStopRepository.findByRouteIdOrderByStopOrderAsc(routeId).stream()
            .map(BusStopJpaEntity::toDomain)
            .collect(Collectors.toList());
        result.put("availableBusStops", routeStops);

        if (child.getBusStopId() != null) {
            busStopRepository.findById(child.getBusStopId()).ifPresent(stop -> {
                if (stop.getRouteId() != null && stop.getRouteId().equals(routeId)) {
                    result.put("assignedBusStopId", stop.getId());
                    result.put("assignedBusStopName", stop.getName());
                    result.put("assignedBusStopAddress", stop.getAddress());
                } else {
                    result.put(
                        "assignmentMessage",
                        "Current assigned bus stop is outside the child's assigned bus route"
                    );
                }
            });
        }

        return result;
    }

    // ========== Journey Operations ==========

    @Override
    public List<Journey> getJourneysByChildIds(List<String> childIds) {
        List<JourneyJpaEntity> entities = journeyRepository.findByChildIdInOrderByDateDescStartTimeDesc(childIds);
        return entities.stream()
            .map(JourneyJpaEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    public Map<String, Object> getJourneySummaryForParent(List<String> childIds) {
        // Get all journeys
        List<Journey> journeys = getJourneysByChildIds(childIds);

        // Count journeys for current month
        String currentMonth = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
        long monthlyCount = journeys.stream()
            .filter(j -> j.getDate() != null && j.getDate().startsWith(currentMonth))
            .count();

        Map<String, Object> result = new HashMap<>();
        result.put("journeys", journeys);
        result.put("monthlyCount", monthlyCount);

        return result;
    }

    @Override
    @Transactional
    public void createSampleJourneys(List<String> childIds) {
        // Implementation for creating sample journey data for testing
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        for (String childId : childIds) {
            // Create 10-15 sample journeys for the current month
            int journeyCount = 10 + new Random().nextInt(6); // 10-15 journeys

            for (int i = 0; i < journeyCount; i++) {
                Journey journey = new Journey();
                journey.setChildId(childId);
                journey.setChildName("Child " + childId);
                journey.setRouteName("Route " + (i % 3 + 1));
                journey.setRouteId((long) (i % 3 + 1));

                // Alternate between PICKUP and DROPOFF
                journey.setJourneyType(i % 2 == 0 ? JourneyType.PICKUP : JourneyType.DROPOFF);
                journey.setStatus(JourneyStatus.COMPLETED);

                // Distribute across current month
                LocalDateTime journeyDate = now.minusDays(i);
                journey.setDate(journeyDate.format(dateFormatter));

                // Set times
                journey.setStartTime(journeyDate.format(TIME_FORMATTER));
                journey.setEndTime(journeyDate.plusMinutes(30).format(TIME_FORMATTER));

                journey.setStartLocation("Home");
                journey.setEndLocation("School");
                journey.setCreatedAt(System.currentTimeMillis());

                // Convert to JPA entity and save
                JourneyJpaEntity entity = JourneyJpaEntity.fromDomain(journey);
                journeyRepository.save(entity);
            }
        }
    }

    @Override
    public List<Journey> getAllJourneys() {
        List<JourneyJpaEntity> entities = journeyRepository.findAllByOrderByDateDescStartTimeDesc();
        return entities.stream()
            .map(JourneyJpaEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    public List<Journey> getJourneysByDateRange(String startDate, String endDate) {
        List<JourneyJpaEntity> entities = journeyRepository.findByDateBetweenOrderByChildIdAndDate(startDate, endDate);
        return entities.stream()
            .map(JourneyJpaEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    public List<Map<String, Object>> getWeeklyAttendance(String weekStartDate) {
        LocalDate startDate = LocalDate.parse(weekStartDate);
        LocalDate endDate = startDate.plusDays(4); // Friday

        // Read from attendance_records (set by drivers via the Flutter app)
        List<AttendanceJpaEntity> records = attendanceRepository.findByDateBetween(startDate, endDate);

        // Build a lookup map of all children that appear in the records
        Set<String> childIds = records.stream()
                .map(AttendanceJpaEntity::getChildId)
                .collect(Collectors.toSet());

        Map<String, com.login.LoginBus.students.infra.ChildJpaEntity> childMap = childRepository
                .findAllById(childIds)
                .stream()
                .collect(Collectors.toMap(
                        com.login.LoginBus.students.infra.ChildJpaEntity::getId,
                        c -> c));

        // Group attendance records by childId → date → session
        Map<String, List<AttendanceJpaEntity>> byChild = records.stream()
                .collect(Collectors.groupingBy(AttendanceJpaEntity::getChildId));

        List<Map<String, Object>> attendanceList = new ArrayList<>();
        String[] weekDays = {"mon", "tue", "wed", "thu", "fri"};

        for (Map.Entry<String, List<AttendanceJpaEntity>> entry : byChild.entrySet()) {
            String childId = entry.getKey();
            List<AttendanceJpaEntity> childRecords = entry.getValue();

            Map<String, Object> attendance = new HashMap<>();
            attendance.put("childId", childId);

            com.login.LoginBus.students.infra.ChildJpaEntity child = childMap.get(childId);
            if (child != null) {
                attendance.put("childName", child.getFullName());
            }

            // Resolve bus plate and route name via busId from attendance record
            Long busId = childRecords.stream()
                    .map(AttendanceJpaEntity::getBusId)
                    .filter(java.util.Objects::nonNull)
                    .findFirst().orElse(null);
            if (busId != null) {
                busRepository.findById(busId).ifPresent(bus -> {
                    attendance.put("busPlateNumber", bus.getPlateNumber());
                    if (bus.getRouteId() != null) {
                        routeRepository.findById(bus.getRouteId())
                                .ifPresent(route -> attendance.put("routeName", route.getName()));
                    }
                });
            }

            for (int i = 0; i < 5; i++) {
                LocalDate day = startDate.plusDays(i);

                // MORNING session: boarded = picked up on way to school
                boolean morningPresent = childRecords.stream().anyMatch(r ->
                        r.getDate().equals(day) &&
                        r.getSession().name().equals("MORNING") &&
                        r.isBoarded());

                // AFTERNOON session: droppedOff = arrived home
                boolean afternoonPresent = childRecords.stream().anyMatch(r ->
                        r.getDate().equals(day) &&
                        r.getSession().name().equals("AFTERNOON") &&
                        r.isDroppedOff());

                List<String> dayMarks = new ArrayList<>();
                dayMarks.add(morningPresent ? "present" : "absent");
                dayMarks.add(afternoonPresent ? "present" : "absent");
                attendance.put(weekDays[i], dayMarks);
            }

            attendanceList.add(attendance);
        }

        return attendanceList;
    }

    // ========== Bus Operations ==========

    @Override
    public Bus getBusById(Long busId) {
        Optional<BusJpaEntity> entityOpt = busRepository.findById(busId);
        return entityOpt.map(BusJpaEntity::toDomain).orElse(null);
    }

    @Override
    public Bus getBusByPlateNumber(String plateNumber) {
        BusJpaEntity entity = busRepository.findByPlateNumber(plateNumber);
        return entity != null ? entity.toDomain() : null;
    }

    @Override
    public List<Bus> getAllBuses() {
        List<BusJpaEntity> entities = busRepository.findAll();
        return entities.stream()
            .map(BusJpaEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public Bus createBus(Bus bus) {
        if (bus.getPlateNumber() == null || bus.getPlateNumber().trim().isEmpty()) {
            throw new IllegalArgumentException("Plate number is required");
        }
        if (busRepository.findByPlateNumber(bus.getPlateNumber()) != null) {
            throw new IllegalArgumentException("Bus with this plate number already exists");
        }
        if (bus.getConductorId() != null && accountsService != null) {
            if (accountsService.getConductorById(bus.getConductorId()) == null) {
                throw new IllegalArgumentException("Conductor not found with ID: " + bus.getConductorId());
            }
        }

        BusJpaEntity entity = BusJpaEntity.fromDomain(bus);
        BusJpaEntity saved = busRepository.save(entity);
        return saved.toDomain();
    }

    @Override
    @Transactional
    public Bus updateBus(Long busId, Bus bus) {
        Optional<BusJpaEntity> existingOpt = busRepository.findById(busId);
        if (existingOpt.isEmpty()) {
            throw new IllegalArgumentException("Bus not found with ID: " + busId);
        }

        BusJpaEntity existing = existingOpt.get();

        if (bus.getPlateNumber() != null && !bus.getPlateNumber().trim().isEmpty()) {
            BusJpaEntity byPlate = busRepository.findByPlateNumber(bus.getPlateNumber());
            if (byPlate != null && !byPlate.getId().equals(busId)) {
                throw new IllegalArgumentException("Bus with this plate number already exists");
            }
            existing.setPlateNumber(bus.getPlateNumber());
        }
        if (bus.getModel() != null) {
            existing.setModel(bus.getModel());
        }
        if (bus.getCapacity() != null) {
            existing.setCapacity(bus.getCapacity());
        }
        if (bus.getStatus() != null) {
            existing.setStatus(bus.getStatus());
        }
        if (bus.getConductorId() != null) {
            if (accountsService != null && accountsService.getConductorById(bus.getConductorId()) == null) {
                throw new IllegalArgumentException("Conductor not found with ID: " + bus.getConductorId());
            }
            existing.setConductorId(bus.getConductorId());
        }
        if (bus.getDeviceId() != null) {
            existing.setDeviceId(bus.getDeviceId());
        }
        if (bus.getRouteId() != null) {
            if (!routeRepository.existsById(bus.getRouteId())) {
                throw new IllegalArgumentException("Route not found with ID: " + bus.getRouteId());
            }
            existing.setRouteId(bus.getRouteId());
        }
        if (bus.getPhotoUrl() != null) {
            existing.setPhotoUrl(bus.getPhotoUrl());
        }

        BusJpaEntity saved = busRepository.save(existing);
        return saved.toDomain();
    }

    @Override
    @Transactional
    public void deleteBus(Long busId) {
        if (!busRepository.existsById(busId)) {
            throw new IllegalArgumentException("Bus not found with ID: " + busId);
        }
        busRepository.deleteById(busId);
    }

    // ========== Route Operations ==========

    @Override
    public List<Route> getAllRoutes() {
        List<RouteJpaEntity> entities = routeRepository.findAll();
        return entities.stream()
            .map(RouteJpaEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    public Route getRouteById(Long routeId) {
        Optional<RouteJpaEntity> entityOpt = routeRepository.findById(routeId);
        return entityOpt.map(RouteJpaEntity::toDomain).orElse(null);
    }

    @Override
    @Transactional
    public Route createRoute(Route route) {
        if (route.getName() == null || route.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Route name is required");
        }

        RouteJpaEntity entity = RouteJpaEntity.fromDomain(route);
        RouteJpaEntity saved = routeRepository.save(entity);
        return saved.toDomain();
    }

    @Override
    @Transactional
    public Route updateRoute(Long routeId, Route route) {
        Optional<RouteJpaEntity> existingOpt = routeRepository.findById(routeId);
        if (existingOpt.isEmpty()) {
            throw new IllegalArgumentException("Route not found with ID: " + routeId);
        }

        RouteJpaEntity existing = existingOpt.get();

        if (route.getName() != null && !route.getName().trim().isEmpty()) {
            existing.setName(route.getName());
        }
        if (route.getDescription() != null) {
            existing.setDescription(route.getDescription());
        }
        if (route.getStartLocation() != null) {
            existing.setStartLocation(route.getStartLocation());
        }
        if (route.getEndLocation() != null) {
            existing.setEndLocation(route.getEndLocation());
        }

        RouteJpaEntity saved = routeRepository.save(existing);
        return saved.toDomain();
    }

    @Override
    @Transactional
    public void deleteRoute(Long routeId) {
        if (!routeRepository.existsById(routeId)) {
            throw new IllegalArgumentException("Route not found with ID: " + routeId);
        }
        routeRepository.deleteById(routeId);
    }

    // ========== Parent-Facing Bus Operations ==========

    @Override
    public Map<String, Object> getAssignedBusDetailsForParent(Long parentId) {
        Map<String, Object> result = new HashMap<>();

        if (studentsService == null) return result;

        // 1. Get all children for this parent
        List<Child> children = studentsService.getChildrenForParent(parentId);

        // 2. Find the first child that has a bus assigned
        Long busId = children.stream()
            .map(Child::getBusId)
            .filter(Objects::nonNull)
            .findFirst()
            .orElse(null);

        if (busId == null) return result;

        // 3. Load the bus
        Optional<BusJpaEntity> busOpt = busRepository.findById(busId);
        if (busOpt.isEmpty()) return result;

        Bus bus = busOpt.get().toDomain();
        result.put("bus", bus);

        // 4. Load the conductor from the bus
        if (bus.getConductorId() != null && accountsService != null) {
            Conductor conductor = accountsService.getConductorById(bus.getConductorId());
            if (conductor != null) {
                result.put("conductor", conductor);
            }
        }

        return result;
    }

    // ========== Parent Bus Stop Assignment Operations ==========

    @Override
    @Transactional
    public void selectBusStop(String childId, String busStopId) {
        if (studentsService == null) {
            throw new IllegalStateException("Students service not available");
        }

        Child child = studentsService.getChildById(childId);
        if (child == null) {
            throw new IllegalArgumentException("Child not found with ID: " + childId);
        }
        if (child.getBusId() == null) {
            throw new IllegalArgumentException("Cannot assign bus stop: no bus is assigned to this child");
        }

        BusJpaEntity busEntity = busRepository.findById(child.getBusId())
            .orElseThrow(() -> new IllegalArgumentException(
                "Assigned bus not found with ID: " + child.getBusId()));
        if (busEntity.getRouteId() == null) {
            throw new IllegalArgumentException("Cannot assign bus stop: no route is assigned to the child's bus");
        }

        BusStopJpaEntity stop = busStopRepository.findById(busStopId)
            .orElseThrow(() -> new IllegalArgumentException("Bus stop not found with ID: " + busStopId));
        if (stop.getRouteId() == null) {
            throw new IllegalArgumentException("Selected bus stop is not assigned to any route");
        }
        if (!busEntity.getRouteId().equals(stop.getRouteId())) {
            throw new IllegalArgumentException(
                "Selected bus stop does not belong to the route assigned to the child's bus"
            );
        }

        studentsService.assignBusStop(childId, busStopId, busEntity.getRouteId());
    }

    @Override
    @Transactional
    public RouteRequest approveRouteRequest(Long requestId, Long routeId) {
        if (studentsService == null) {
            throw new IllegalStateException("Students service not available");
        }

        RouteRequestJpaEntity requestEntity = routeRequestRepository.findById(requestId)
            .orElseThrow(() -> new IllegalArgumentException("Route request not found with ID: " + requestId));

        if (requestEntity.getStatus() != RouteRequestStatus.PENDING) {
            throw new IllegalArgumentException("Only PENDING requests can be approved");
        }

        if (!routeRepository.existsById(routeId)) {
            throw new IllegalArgumentException("Route not found with ID: " + routeId);
        }

        Child child = studentsService.getChildById(requestEntity.getChildId());
        if (child == null) {
            throw new IllegalArgumentException("Child not found with ID: " + requestEntity.getChildId());
        }
        if (child.getBusId() != null) {
            BusJpaEntity busEntity = busRepository.findById(child.getBusId())
                .orElseThrow(() -> new IllegalArgumentException(
                    "Assigned bus not found with ID: " + child.getBusId()));
            if (busEntity.getRouteId() != null && !busEntity.getRouteId().equals(routeId)) {
                throw new IllegalArgumentException(
                    "Approved route must match the route assigned to the child's bus"
                );
            }
        }

        // Create a new bus stop from the request location
        BusStopJpaEntity newStop = new BusStopJpaEntity();
        newStop.setLatitude(requestEntity.getLatitude());
        newStop.setLongitude(requestEntity.getLongitude());
        newStop.setAddress(requestEntity.getAddress() != null ? requestEntity.getAddress() : "");
        newStop.setDescription(requestEntity.getDescription() != null ? requestEntity.getDescription() : "");
        newStop.setName(requestEntity.getAddress() != null && !requestEntity.getAddress().isEmpty()
            ? requestEntity.getAddress()
            : "Stop (" + requestEntity.getLatitude() + ", " + requestEntity.getLongitude() + ")");
        newStop.setRouteId(routeId);
        newStop.setStopOrder(0);

        BusStopJpaEntity savedStop = busStopRepository.save(newStop);

        // Link the child to the new stop and route
        studentsService.assignBusStop(requestEntity.getChildId(), savedStop.getId(), routeId);

        // Mark the request as approved
        requestEntity.setStatus(RouteRequestStatus.APPROVED);
        RouteRequestJpaEntity saved = routeRequestRepository.save(requestEntity);

        return saved.toDomain();
    }

    // ========== TransportPublicService Implementation ==========

    @Override
    public BusTracking getActiveBusTracking(String childId) {
        return getActiveBusTrackingForChild(childId);
    }

    @Override
    public Journey getJourneyById(Long journeyId) {
        Optional<JourneyJpaEntity> entityOpt = journeyRepository.findById(journeyId);
        return entityOpt.map(JourneyJpaEntity::toDomain).orElse(null);
    }
}
