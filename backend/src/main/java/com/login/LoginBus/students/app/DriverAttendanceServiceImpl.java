package com.login.LoginBus.students.app;

import com.login.LoginBus.accounts.infra.ConductorJpaEntity;
import com.login.LoginBus.accounts.infra.ConductorRepository;
import com.login.LoginBus.notifications.app.NotificationsPublicService;
import com.login.LoginBus.notifications.domain.NotificationType;
import com.login.LoginBus.notifications.domain.NotificationCategory;
import com.login.LoginBus.students.api.AttendanceWithChildDto;
import com.login.LoginBus.students.api.MarkAttendanceRequest;
import com.login.LoginBus.students.domain.AttendanceSession;
import com.login.LoginBus.students.infra.AttendanceJpaEntity;
import com.login.LoginBus.students.infra.AttendanceRepository;
import com.login.LoginBus.students.infra.ChildJpaEntity;
import com.login.LoginBus.students.infra.ChildRepository;
import com.login.LoginBus.transport.infra.BusJpaEntity;
import com.login.LoginBus.transport.infra.BusRepository;
import com.login.LoginBus.transport.infra.BusStopRepository;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class DriverAttendanceServiceImpl implements DriverAttendanceService {

    private final ConductorRepository conductorRepository;
    private final BusRepository busRepository;
    private final ChildRepository childRepository;
    private final AttendanceRepository attendanceRepository;
    private final NotificationsPublicService notificationsPublicService;
    private final BusStopRepository busStopRepository;

    public DriverAttendanceServiceImpl(ConductorRepository conductorRepository,
                                        BusRepository busRepository,
                                        ChildRepository childRepository,
                                        AttendanceRepository attendanceRepository,
                                        NotificationsPublicService notificationsPublicService,
                                        BusStopRepository busStopRepository) {
        this.conductorRepository = conductorRepository;
        this.busRepository = busRepository;
        this.childRepository = childRepository;
        this.attendanceRepository = attendanceRepository;
        this.notificationsPublicService = notificationsPublicService;
        this.busStopRepository = busStopRepository;
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
            // Confirming attendance cancels any prior absent mark
            if (newValue) { record.setAbsent(false); record.setAbsentAt(null); }
        } else if ("DROPPED_OFF".equals(action)) {
            record.setDroppedOff(newValue);
            record.setDroppedOffAt(newValue ? now : null);
            // Confirming attendance cancels any prior absent mark
            if (newValue) { record.setAbsent(false); record.setAbsentAt(null); }
        } else {
            record.setAbsent(newValue);
            record.setAbsentAt(newValue ? now : null);
            // Marking absent cancels any prior boarding/drop-off confirmation
            if (newValue) {
                record.setBoarded(false);
                record.setBoardedAt(null);
                record.setDroppedOff(false);
                record.setDroppedOffAt(null);
            }
        }

        AttendanceJpaEntity saved = attendanceRepository.save(record);

        // Send notification to parent when confirming (not when unchecking)
        if (newValue) {
            sendAttendanceNotification(child, conductor, sess, action);
        }

        return toDto(child, sess, saved);
    }

    // ── Notification helper ────────────────────────────────────────────────────

    private void sendAttendanceNotification(ChildJpaEntity child, ConductorJpaEntity conductor, AttendanceSession sess, String action) {
        System.out.println("[NOTIF] sendAttendanceNotification called. childId=" + child.getId()
                + " parentId=" + child.getParentId() + " action=" + action + " session=" + sess);

        // child.parentId is already the parent's users.id — no parents-table lookup needed
        Long parentUserId = child.getParentId();
        if (parentUserId == null) {
            System.out.println("[NOTIF] SKIP: child has no parentId");
            return;
        }

        System.out.println("[NOTIF] Sending to parentUserId=" + parentUserId);

        String childName = child.getFullName();
        String title;
        String message;
        NotificationCategory category;

        if ("ABSENT".equals(action)) {
            title = "Your child has been marked absent";
            message = sess == AttendanceSession.MORNING
                    ? childName + " was not present for the morning bus pickup today."
                    : childName + " was not present for the afternoon bus drop-off today.";
            category = NotificationCategory.ABSENCE_CREATED;
        } else if (sess == AttendanceSession.MORNING) {
            if ("BOARDED".equals(action)) {
                title = "Your child has boarded the bus";
                message = childName + " has boarded the school bus and is on their way to school.";
                category = NotificationCategory.STUDENT_BOARDED_BUS;
            } else {
                title = "Your child has arrived at school";
                message = childName + " has been dropped off at school safely.";
                category = NotificationCategory.STUDENT_EXITED_BUS;
            }
        } else {
            if ("BOARDED".equals(action)) {
                title = "Your child is heading home";
                message = childName + " has boarded the bus and is on their way home.";
                category = NotificationCategory.STUDENT_BOARDED_BUS;
            } else {
                title = "Your child has been dropped off";
                message = childName + " has been dropped off at their stop safely.";
                category = NotificationCategory.STUDENT_EXITED_BUS;
            }
        }

        try {

            notificationsPublicService.sendNotification(
                    parentUserId,
                    conductor.getUserId(),
                    NotificationType.INFO,
                    category,
                    title,
                    message
            );
            System.out.println("[NOTIF] SUCCESS: notification sent to userId=" + parentUserId);
        } catch (Exception e) {
            System.err.println("[NOTIF] FAILED: " + e.getClass().getSimpleName() + ": " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    @Transactional(readOnly = true)
    public void notifyStopArrival(Jwt jwt, String stopId, String session) {
        ConductorJpaEntity conductor = resolveConductor(jwt);
        BusJpaEntity bus = resolveBus(conductor);
        AttendanceSession sess = parseSession(session);

        String stopName = busStopRepository.findById(stopId)
                .map(s -> s.getName())
                .orElse("a bus stop");

        // A child boards and alights at the same stop, so the same busStopId
        // applies for both the morning pickup and afternoon drop-off session.
        List<ChildJpaEntity> children = childRepository.findByBusIdAndBusStopId(bus.getId(), stopId);

        for (ChildJpaEntity child : children) {
            Long parentUserId = child.getParentId();
            if (parentUserId == null) continue;
            try {
                String title = "Bus has arrived at " + stopName;
                String message = (sess == AttendanceSession.MORNING)
                        ? child.getFullName() + " should board the bus at " + stopName + " shortly."
                        : child.getFullName() + " will be dropped off at " + stopName + " shortly.";
                notificationsPublicService.sendNotification(
                        parentUserId,
                        conductor.getUserId(),
                        NotificationType.INFO,
                        NotificationCategory.BUS_REACHED_STOP,
                        title,
                        message
                );
            } catch (Exception e) {
                System.err.println("[NOTIF] Arrival notification failed for child " + child.getId() + ": " + e.getMessage());
            }
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
                rec != null ? rec.getDroppedOffAt() : null,
                rec != null && rec.isAbsent(),
                rec != null ? rec.getAbsentAt() : null
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
        if ("ABSENT".equalsIgnoreCase(action)) return "ABSENT";
        throw new IllegalArgumentException("action must be BOARDED, DROPPED_OFF, or ABSENT");
    }
}

