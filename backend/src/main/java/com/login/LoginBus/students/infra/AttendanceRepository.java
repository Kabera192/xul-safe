package com.login.LoginBus.students.infra;

import com.login.LoginBus.students.domain.AttendanceSession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface AttendanceRepository extends JpaRepository<AttendanceJpaEntity, Long> {

    /** All attendance records for a given bus/date/session. */
    List<AttendanceJpaEntity> findByBusIdAndDateAndSession(
            Long busId, LocalDate date, AttendanceSession session);

    /** All attendance records across all buses for a date range (admin use). */
    List<AttendanceJpaEntity> findByDateBetween(LocalDate startDate, LocalDate endDate);

    /** Look up an individual record for upsert. */
    Optional<AttendanceJpaEntity> findByChildIdAndDateAndSession(
            String childId, LocalDate date, AttendanceSession session);
}
