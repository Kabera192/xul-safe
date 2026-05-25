package com.login.LoginBus.students.infra;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.login.LoginBus.students.domain.Absence;
import com.login.LoginBus.students.domain.AbsenceStatus;
import com.login.LoginBus.students.domain.AbsenceType;
import jakarta.persistence.*;

import java.time.LocalDate;

/**
 * JPA Entity for Absence persistence.
 * Handles database mapping and conversion to/from domain entity.
 */
@Entity
@Table(name = "absences")
public class AbsenceJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "child_id", nullable = false)
    @JsonProperty("childId")
    private String childId;

    @Column(name = "parent_id", nullable = false)
    @JsonProperty("parentId")
    private Long parentId;

    @Column(name = "absence_type", nullable = false)
    @JsonProperty("absenceType")
    @Enumerated(EnumType.STRING)
    private AbsenceType absenceType;

    @Column(name = "start_date", nullable = false)
    @JsonProperty("startDate")
    private LocalDate startDate;

    @Column(name = "end_date", nullable = false)
    @JsonProperty("endDate")
    private LocalDate endDate;

    @Column(nullable = false)
    @JsonProperty("status")
    @Enumerated(EnumType.STRING)
    private AbsenceStatus status;

    @Column(name = "created_at")
    private Long createdAt;

    @Column(name = "updated_at")
    private Long updatedAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = System.currentTimeMillis();
        }
        if (updatedAt == null) {
            updatedAt = System.currentTimeMillis();
        }
        if (status == null) {
            status = AbsenceStatus.ACTIVE;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = System.currentTimeMillis();
    }

    // No-arg constructor (required for JPA)
    public AbsenceJpaEntity() {
    }

    /**
     * Convert JPA entity to domain entity.
     *
     * @return Domain Absence entity
     */
    public Absence toDomain() {
        return new Absence(
            this.id,
            this.childId,
            this.parentId,
            this.absenceType,
            this.startDate,
            this.endDate,
            this.status,
            this.createdAt,
            this.updatedAt
        );
    }

    /**
     * Convert domain entity to JPA entity.
     *
     * @param absence Domain Absence entity
     * @return JPA Absence entity
     */
    public static AbsenceJpaEntity fromDomain(Absence absence) {
        AbsenceJpaEntity entity = new AbsenceJpaEntity();
        entity.setId(absence.getId());
        entity.setChildId(absence.getChildId());
        entity.setParentId(absence.getParentId());
        entity.setAbsenceType(absence.getAbsenceType());
        entity.setStartDate(absence.getStartDate());
        entity.setEndDate(absence.getEndDate());
        entity.setStatus(absence.getStatus());
        entity.createdAt = absence.getCreatedAt();
        entity.updatedAt = absence.getUpdatedAt();
        return entity;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getChildId() {
        return childId;
    }

    public void setChildId(String childId) {
        this.childId = childId;
    }

    public Long getParentId() {
        return parentId;
    }

    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }

    public AbsenceType getAbsenceType() {
        return absenceType;
    }

    public void setAbsenceType(AbsenceType absenceType) {
        this.absenceType = absenceType;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public AbsenceStatus getStatus() {
        return status;
    }

    public void setStatus(AbsenceStatus status) {
        this.status = status;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public Long getUpdatedAt() {
        return updatedAt;
    }
}
