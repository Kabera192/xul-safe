package com.login.LoginBus.students.infra;

import com.login.LoginBus.students.domain.AbsenceStatus;
import com.login.LoginBus.students.domain.AbsenceType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface AbsenceRepository extends JpaRepository<AbsenceJpaEntity, Long> {
    List<AbsenceJpaEntity> findByChildId(String childId);
    List<AbsenceJpaEntity> findByParentId(Long parentId);
    List<AbsenceJpaEntity> findByParentIdAndStatus(Long parentId, AbsenceStatus status);
    List<AbsenceJpaEntity> findByChildIdAndStatus(String childId, AbsenceStatus status);
    List<AbsenceJpaEntity> findByChildIdAndStartDateBetween(String childId, LocalDate startDate, LocalDate endDate);

    /** Find active absences for a set of children that cover the given date. */
    @Query("SELECT a FROM AbsenceJpaEntity a " +
           "WHERE a.childId IN :childIds " +
           "AND a.status = 'ACTIVE' " +
           "AND a.startDate <= :date " +
           "AND a.endDate >= :date " +
           "AND a.absenceType IN :types")
    List<AbsenceJpaEntity> findActiveAbsencesForChildren(
            @Param("childIds") List<String> childIds,
            @Param("date") LocalDate date,
            @Param("types") List<AbsenceType> types);
}

