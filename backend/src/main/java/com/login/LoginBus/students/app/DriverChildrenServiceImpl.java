package com.login.LoginBus.students.app;

import com.login.LoginBus.accounts.infra.ConductorJpaEntity;
import com.login.LoginBus.accounts.infra.ConductorRepository;
import com.login.LoginBus.students.api.AssignChildrenToStopRequest;
import com.login.LoginBus.students.api.DriverChildSummaryDto;
import com.login.LoginBus.students.domain.AbsenceType;
import com.login.LoginBus.students.infra.AbsenceJpaEntity;
import com.login.LoginBus.students.infra.AbsenceRepository;
import com.login.LoginBus.students.infra.ChildJpaEntity;
import com.login.LoginBus.students.infra.ChildRepository;
import com.login.LoginBus.transport.infra.BusJpaEntity;
import com.login.LoginBus.transport.infra.BusRepository;
import com.login.LoginBus.transport.infra.StopJpaEntity;
import com.login.LoginBus.transport.infra.StopRepository;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class DriverChildrenServiceImpl implements DriverChildrenService {

    private final ConductorRepository conductorRepository;
    private final BusRepository busRepository;
    private final ChildRepository childRepository;
    private final AbsenceRepository absenceRepository;
    private final StopRepository stopRepository;

    public DriverChildrenServiceImpl(ConductorRepository conductorRepository,
                                     BusRepository busRepository,
                                     ChildRepository childRepository,
                                     AbsenceRepository absenceRepository,
                                     StopRepository stopRepository) {
        this.conductorRepository = conductorRepository;
        this.busRepository = busRepository;
        this.childRepository = childRepository;
        this.absenceRepository = absenceRepository;
        this.stopRepository = stopRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public List<DriverChildSummaryDto> getBusChildren(Jwt jwt) {
        BusJpaEntity bus = resolveDriverBus(jwt);
        return childRepository.findByBusId(bus.getId())
                .stream().map(this::toSummary).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public DriverChildSummaryDto getChild(Jwt jwt, String childId) {
        BusJpaEntity bus = resolveDriverBus(jwt);
        ChildJpaEntity child = childRepository.findById(childId)
                .orElseThrow(() -> new IllegalArgumentException("Child not found"));
        if (!bus.getId().equals(child.getBusId())) {
            throw new IllegalStateException("Child is not on your bus");
        }
        return toSummary(child);
    }

    @Override
    @Transactional(readOnly = true)
    public List<DriverChildSummaryDto> getAbsentChildren(Jwt jwt, LocalDate date, String journey) {
        BusJpaEntity bus = resolveDriverBus(jwt);
        List<ChildJpaEntity> busChildren = childRepository.findByBusId(bus.getId());
        if (busChildren.isEmpty()) return List.of();

        List<String> childIds = busChildren.stream().map(ChildJpaEntity::getId).toList();
        List<AbsenceType> types = absenceTypesForJourney(journey);
        List<AbsenceJpaEntity> absences = absenceRepository.findActiveAbsencesForChildren(childIds, date, types);

        Set<String> absentIds = absences.stream()
                .map(AbsenceJpaEntity::getChildId).collect(Collectors.toSet());

        return busChildren.stream()
                .filter(c -> absentIds.contains(c.getId()))
                .map(this::toSummary).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<DriverChildSummaryDto> getPresentChildren(Jwt jwt, LocalDate date, String journey) {
        BusJpaEntity bus = resolveDriverBus(jwt);
        List<ChildJpaEntity> busChildren = childRepository.findByBusId(bus.getId());
        if (busChildren.isEmpty()) return List.of();

        List<String> childIds = busChildren.stream().map(ChildJpaEntity::getId).toList();
        List<AbsenceType> types = absenceTypesForJourney(journey);
        List<AbsenceJpaEntity> absences = absenceRepository.findActiveAbsencesForChildren(childIds, date, types);

        Set<String> absentIds = absences.stream()
                .map(AbsenceJpaEntity::getChildId).collect(Collectors.toSet());

        return busChildren.stream()
                .filter(c -> !absentIds.contains(c.getId()))
                .map(this::toSummary).toList();
    }

    @Override
    @Transactional
    public void assignChildrenToStop(Jwt jwt, Long stopId, AssignChildrenToStopRequest request) {
        BusJpaEntity bus = resolveDriverBus(jwt);
        StopJpaEntity stop = stopRepository.findById(stopId)
                .orElseThrow(() -> new IllegalArgumentException("Stop not found"));

        if (bus.getRouteId() == null || !bus.getRouteId().equals(stop.getRouteId())) {
            throw new IllegalStateException("Stop does not belong to your route");
        }

        boolean isPickup = "PICKUP".equalsIgnoreCase(request.getStopType());
        boolean isDropoff = "DROPOFF".equalsIgnoreCase(request.getStopType());

        if (!isPickup && !isDropoff) {
            throw new IllegalArgumentException("stop_type must be PICKUP or DROPOFF");
        }

        List<String> childIds = request.getChildIds();
        if (childIds == null || childIds.isEmpty()) return;

        for (String childId : childIds) {
            childRepository.findById(childId).ifPresent(child -> {
                if (bus.getId().equals(child.getBusId())) {
                    if (isPickup) child.setPickupStopId(stopId);
                    else child.setDropoffStopId(stopId);
                    childRepository.save(child);
                }
            });
        }
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

    private List<AbsenceType> absenceTypesForJourney(String journey) {
        if ("RETURN".equalsIgnoreCase(journey)) {
            return List.of(AbsenceType.EVENING, AbsenceType.MULTIPLE_DAYS);
        }
        // Default / MORNING
        return List.of(AbsenceType.MORNING, AbsenceType.MULTIPLE_DAYS);
    }

    private DriverChildSummaryDto toSummary(ChildJpaEntity child) {
        return new DriverChildSummaryDto(
                child.getId(),
                child.getFullName(),
                child.getGrade(),
                child.getGender() != null ? child.getGender().name() : null,
                child.getPhotoUrl(),
                child.getPickupStopId(),
                child.getDropoffStopId()
        );
    }
}
