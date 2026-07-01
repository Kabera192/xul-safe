package com.login.LoginBus.students.app;

import com.login.LoginBus.accounts.infra.ConductorJpaEntity;
import com.login.LoginBus.accounts.infra.ConductorRepository;
import com.login.LoginBus.notifications.app.NotificationsPublicService;
import com.login.LoginBus.notifications.domain.NotificationCategory;
import com.login.LoginBus.notifications.domain.NotificationType;
import com.login.LoginBus.students.domain.Absence;
import com.login.LoginBus.students.domain.Child;
import com.login.LoginBus.students.infra.*;
import com.login.LoginBus.transport.infra.BusJpaEntity;
import com.login.LoginBus.transport.infra.BusRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Service implementation for Students module.
 * Implements both StudentsService and StudentsPublicService.
 */
@Service
public class StudentsServiceImpl implements StudentsService, StudentsPublicService {

    @Autowired
    private ChildRepository childRepository;

    @Autowired
    private AbsenceRepository absenceRepository;

    @Autowired
    private BusRepository busRepository;

    @Autowired
    private ConductorRepository conductorRepository;

    @Autowired
    private NotificationsPublicService notificationsPublicService;

    // ========== Child Operations ==========

    @Override
    public List<Child> getChildrenForParent(Long parentId) {
        List<ChildJpaEntity> entities = childRepository.findByParentId(parentId);
        return entities.stream()
            .map(ChildJpaEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    public List<Child> getAllChildren() {
        List<ChildJpaEntity> entities = childRepository.findAll();
        return entities.stream()
            .map(ChildJpaEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    public Child getChildById(String childId) {
        Optional<ChildJpaEntity> entityOpt = childRepository.findById(childId);
        return entityOpt.map(ChildJpaEntity::toDomain).orElse(null);
    }

    @Override
    @Transactional
    public Child createChild(Child child) {
        // Set creation timestamp
        if (child.getCreatedAt() == null) {
            child.setCreatedAt(System.currentTimeMillis());
        }

        // Generate ID if not provided
        if (child.getId() == null || child.getId().isEmpty()) {
            child.setId(java.util.UUID.randomUUID().toString());
        }

        ChildJpaEntity entity = ChildJpaEntity.fromDomain(child);
        ChildJpaEntity saved = childRepository.save(entity);

        return saved.toDomain();
    }

    @Override
    @Transactional
    public Child updateChild(String childId, Child child) {
        Optional<ChildJpaEntity> existingOpt = childRepository.findById(childId);

        if (existingOpt.isEmpty()) {
            throw new IllegalArgumentException("Child not found with ID: " + childId);
        }

        ChildJpaEntity existing = existingOpt.get();

        // Update fields
        if (child.getFullName() != null) {
            existing.setFullName(child.getFullName());
        }
        if (child.getBirthDate() != null) {
            existing.setBirthDate(child.getBirthDate());
        }
        if (child.getGender() != null) {
            existing.setGender(child.getGender());
        }
        if (child.getGrade() != null) {
            existing.setGrade(child.getGrade());
        }
        if (child.getPhotoUrl() != null) {
            existing.setPhotoUrl(child.getPhotoUrl());
        }
        if (child.getParentId() != null) {
            existing.setParentId(child.getParentId());
        }
        // Update bus, route, and bus stop assignments
        existing.setBusId(child.getBusId());
        existing.setRouteId(child.getRouteId());
        existing.setBusStopId(child.getBusStopId());

        ChildJpaEntity saved = childRepository.save(existing);
        return saved.toDomain();
    }

    @Override
    @Transactional
    public void deleteChild(String childId) {
        if (!childRepository.existsById(childId)) {
            throw new IllegalArgumentException("Child not found with ID: " + childId);
        }
        childRepository.deleteById(childId);
    }

    @Override
    public boolean childExists(String childId) {
        return childRepository.existsById(childId);
    }

    // ========== Absence Operations ==========

    @Override
    public List<Absence> getAllAbsences() {
        return absenceRepository.findAll().stream()
            .map(entity -> {
                Absence absence = entity.toDomain();
                // Enrich with child name
                childRepository.findById(absence.getChildId()).ifPresent(child ->
                    absence.setChildName(child.getFullName())
                );
                return absence;
            })
            .collect(Collectors.toList());
    }

    @Override
    public List<Absence> getAbsencesForChild(String childId) {
        List<AbsenceJpaEntity> entities = absenceRepository.findByChildId(childId);
        return entities.stream()
            .map(AbsenceJpaEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    public List<Absence> getAbsencesForParent(Long parentId) {
        List<AbsenceJpaEntity> entities = absenceRepository.findByParentId(parentId);
        return entities.stream()
            .map(AbsenceJpaEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public Absence createAbsence(Absence absence) {
        // Set timestamps
        if (absence.getCreatedAt() == null) {
            absence.setCreatedAt(System.currentTimeMillis());
        }
        if (absence.getUpdatedAt() == null) {
            absence.setUpdatedAt(System.currentTimeMillis());
        }

        AbsenceJpaEntity entity = AbsenceJpaEntity.fromDomain(absence);
        AbsenceJpaEntity saved = absenceRepository.save(entity);

        // Notify the driver assigned to this child's bus
        sendAbsenceNotificationToDriver(absence);

        return saved.toDomain();
    }

    private void sendAbsenceNotificationToDriver(Absence absence) {
        try {
            ChildJpaEntity child = childRepository.findById(absence.getChildId()).orElse(null);
            if (child == null || child.getBusId() == null) return;

            BusJpaEntity bus = busRepository.findById(child.getBusId()).orElse(null);
            if (bus == null || bus.getConductorId() == null) return;

            ConductorJpaEntity conductor = conductorRepository.findById(bus.getConductorId()).orElse(null);
            if (conductor == null || conductor.getUserId() == null) return;

            String childName = child.getFullName();
            String absenceTypeLabel = switch (absence.getAbsenceType()) {
                case MORNING -> "this morning";
                case EVENING -> "this evening";
                case MULTIPLE_DAYS -> "from " + absence.getStartDate() + " to " + absence.getEndDate();
            };

            notificationsPublicService.sendNotification(
                    conductor.getUserId(),
                    absence.getParentId(),
                    NotificationType.INFO,
                    NotificationCategory.ABSENCE_CREATED,
                    "Absence: " + childName,
                    childName + " will not be attending " + absenceTypeLabel + "."
            );
        } catch (Exception e) {
            // Don't fail the absence creation if notification delivery fails
        }
    }

    @Override
    @Transactional
    public Absence updateAbsence(Long absenceId, Absence absence) {
        Optional<AbsenceJpaEntity> existingOpt = absenceRepository.findById(absenceId);

        if (existingOpt.isEmpty()) {
            throw new IllegalArgumentException("Absence not found with ID: " + absenceId);
        }

        AbsenceJpaEntity existing = existingOpt.get();

        // Update fields
        existing.setAbsenceType(absence.getAbsenceType());
        existing.setStartDate(absence.getStartDate());
        existing.setEndDate(absence.getEndDate());
        existing.setStatus(absence.getStatus());

        AbsenceJpaEntity saved = absenceRepository.save(existing);
        return saved.toDomain();
    }

    @Override
    @Transactional
    public void deleteAbsence(Long absenceId) {
        if (!absenceRepository.existsById(absenceId)) {
            throw new IllegalArgumentException("Absence not found with ID: " + absenceId);
        }
        absenceRepository.deleteById(absenceId);
    }

    @Override
    public List<Absence> getActiveAbsencesForParent(Long parentId) {
        List<AbsenceJpaEntity> entities = absenceRepository.findByParentIdAndStatus(parentId, com.login.LoginBus.students.domain.AbsenceStatus.ACTIVE);
        return entities.stream()
            .map(AbsenceJpaEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public Absence completeAbsence(Long absenceId) {
        Optional<AbsenceJpaEntity> existingOpt = absenceRepository.findById(absenceId);

        if (existingOpt.isEmpty()) {
            throw new IllegalArgumentException("Absence not found with ID: " + absenceId);
        }

        AbsenceJpaEntity existing = existingOpt.get();
        existing.setStatus(com.login.LoginBus.students.domain.AbsenceStatus.COMPLETED);

        AbsenceJpaEntity saved = absenceRepository.save(existing);
        return saved.toDomain();
    }

    // ========== StudentsPublicService Implementation ==========

    @Override
    public List<Child> getChildrenForRoute(Long routeId) {
        // TODO: Implement when ChildRoute relationship is added
        return List.of();
    }

    @Override
    @Transactional
    public void assignBusStop(String childId, String busStopId, Long routeId) {
        ChildJpaEntity entity = childRepository.findById(childId)
            .orElseThrow(() -> new IllegalArgumentException("Child not found with ID: " + childId));
        entity.setBusStopId(busStopId);
        entity.setRouteId(routeId);
        childRepository.save(entity);
    }
}
