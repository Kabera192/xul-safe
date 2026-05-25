package com.login.LoginBus.students.app;

import com.login.LoginBus.accounts.infra.ConductorJpaEntity;
import com.login.LoginBus.accounts.infra.ConductorRepository;
import com.login.LoginBus.accounts.infra.ParentJpaEntity;
import com.login.LoginBus.accounts.infra.ParentRepository;
import com.login.LoginBus.notifications.app.NotificationsPublicService;
import com.login.LoginBus.students.api.AttendanceWithChildDto;
import com.login.LoginBus.students.api.MarkAttendanceRequest;
import com.login.LoginBus.students.domain.AttendanceSession;
import com.login.LoginBus.students.infra.AttendanceJpaEntity;
import com.login.LoginBus.students.infra.AttendanceRepository;
import com.login.LoginBus.students.infra.ChildJpaEntity;
import com.login.LoginBus.students.infra.ChildRepository;
import com.login.LoginBus.transport.infra.BusJpaEntity;
import com.login.LoginBus.transport.infra.BusRepository;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class DriverAttendanceServiceImpl implements DriverAttendanceService {

    private final ConductorRepository conductorRepository;
    private final BusRepository busRepository;
    private final ChildRepository childRepository;
    private final AttendanceRepository attendanceRepository;
    private final ParentRepository parentRepository;
    private final NotificationsPublicService notificationsPublicService;

    public DriverAttendanceServiceImpl(ConductorRepository conductorRepository,
                                        BusRepository busRepository,
                                        ChildRepository childRepository,
                                        AttendanceRepository attendanceRepository,
                                        ParentRepository parentRepository,
                                        NotificationsPublicService notificationsPublicService) {
        this.conductorRepository = conductorRepository;
        this.busRepository = busRepository;
        this.childRepository = childRepository;
        this.attendanceRepository = attendanceRepository;
        this.parentRepository = parentRepository;
        this.notificationsPublicService = notificationsPublicService;
    }

    @Override
    @Transactional(readOnly = true)
    public List<AttendanceWithChildDto> getSessionAttendance(Jwt jwt, LocalDate date, String session) {
        ConductorJpaEntity conductor = resolveConductor(jwt);
        BusJpaEntity bus = resolveBus(conductor);
        AttendanceSession sess = parseSession(session);

        long endOfDayMillis = LocalDateTime.of(date.getYear(), date.getMonth(), date.getDayOfMonth(),
                23, 59, 59).toInstant(ZoneOffset.UTC).toEpochMilli();

        List<ChildJpaEntity> busChildren = childRepository.findByBusId(bus.getId())
                .stream()
                .filter(c -> c.getCreatedAt() == null || c.getCreatedAt() <= endOfDayMillis)
                .toList();

        Map<String, AttendanceJpaEntity> recordMap =
                attendanceRepository.findByBusIdAndDateAndSession(bus.getId(), date, sess)
                        .stream()
                        .collect(Collectors.toMap(AttendanceJpaEntity::getChildId, r -> r));

        return busChildren.stream()
                .map(child -> toDto(child, sess, recordMap.get(child.getId())))
                .toList();
    }

    @Override
    @Transactional
    public AttendanceWithChildDto markAttendance(Jwt jwt, MarkAttendanceRequest request) {
        ConductorJpaEntity conductor = resolveConductor(jwt);
        BusJpaEntity bus = resolveBus(conductor);
        AttendanceSession sess = parseSession(request.getSession());
        String action = parseAction(request.getAction());

        ChildJpaEntity child = childRepository.findById(request.getChildId())
                .orElseThrow(() -> new IllegalArgumentException("Child not found"));

        if (!bus.getId().equals(child.getBusId())) {
            throw new IllegalStateException("Child is not on your bus");
        }

        // Upsert attendance record
        AttendanceJpaEntity record = attendanceRepository
                .findByChildIdAndDateAndSession(request.getChildId(), request.getDate(), sess)
                .orElseGet(() -> {
                    AttendanceJpaEntity r = new AttendanceJpaEntity();
                    r.setChildId(request.getChildId());
                    r.setBusId(bus.getId());
                    r.setConductorId(conductor.getId());
                    r.setDate(request.getDate());
                    r.setSession(sess);
                    return r;
                });

        long now = System.currentTimeMillis();
        boolean newValue = request.isConfirmed();

        if ("BOARDED".equals(action)) {
            record.setBoarded(newValue);
            record.setBoardedAt(newValue ? now : null);
        } else {
            record.setDroppedOff(newValue);
            record.setDroppedOffAt(newValue ? now : null);
        }

        AttendanceJpaEntity saved = attendanceRepository.save(record);

        // Send notification to parent when confirming (not when unchecking)
        if (newValue) {
            sendAttendanceNotification(child, sess, action);
        }

        return toDto(child, sess, saved);
    }

    // ── Notification helper ────────────────────────────────────────────────────

    private void sendAttendanceNotification(ChildJpaEntity child, AttendanceSession sess, String action) {
        if (child.getParentId() == null) return;

        Optional<ParentJpaEntity> parentOpt = parentRepository.findById(child.getParentId());
        if (parentOpt.isEmpty()) return;

        Long parentUserId = parentOpt.get().getUserId();
        if (parentUserId == null) return;

        String childName = child.getFullName();
        String title;
        String message;

        if (sess == AttendanceSession.MORNING) {
            if ("BOARDED".equals(action)) {
                title = "Your child has boarded the bus";
                message = childName + " has boarded the school bus and is on their way to school.";
            } else {
                title = "Your child has arrived at school";
                message = childName + " has been dropped off at school safely.";
            }
        } else {
            if ("BOARDED".equals(action)) {
                title = "Your child is heading home";
                message = childName + " has boarded the bus and is on their way home.";
            } else {
                title = "Your child has been dropped off";
                message = childName + " has been dropped off at their stop safely.";
            }
        }

        try {
            notificationsPublicService.sendNotification(parentUserId, title, message);
        } catch (Exception e) {
            // Log but don't fail the attendance marking if notification delivery fails
        }
    }

    // ── helpers ───────────────────────────────────────────────────────────────

    private AttendanceWithChildDto toDto(ChildJpaEntity child, AttendanceSession sess, AttendanceJpaEntity rec) {
        return new AttendanceWithChildDto(
                child.getId(),
                child.getFullName(),
                child.getGrade(),
                child.getGender() != null ? child.getGender().name() : null,
                child.getPhotoUrl(),
                sess.name(),
                rec != null && rec.isBoarded(),
                rec != null ? rec.getBoardedAt() : null,
                rec != null && rec.isDroppedOff(),
                rec != null ? rec.getDroppedOffAt() : null
        );
    }

    private ConductorJpaEntity resolveConductor(Jwt jwt) {
        Long userId = jwt.getClaim("user_id");
        if (userId == null) throw new IllegalArgumentException("Invalid token");
        return conductorRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalStateException("Conductor profile not found"));
    }

    private BusJpaEntity resolveBus(ConductorJpaEntity conductor) {
        return busRepository.findByConductorId(conductor.getId())
                .orElseThrow(() -> new IllegalStateException("No bus assigned to you"));
    }

    private AttendanceSession parseSession(String session) {
        try {
            return AttendanceSession.valueOf(session.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("session must be MORNING or AFTERNOON");
        }
    }

    private String parseAction(String action) {
        if ("BOARDED".equalsIgnoreCase(action)) return "BOARDED";
        if ("DROPPED_OFF".equalsIgnoreCase(action)) return "DROPPED_OFF";
        throw new IllegalArgumentException("action must be BOARDED or DROPPED_OFF");
    }
}

