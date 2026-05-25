package com.login.LoginBus.students.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDate;

/**
 * Pure domain entity for Absence.
 * Contains NO framework annotations - only business logic.
 */
public class Absence {

    private Long id;
    private String childId;
    private String childName; // enriched field, not stored in DB
    private Long parentId;
    private AbsenceType absenceType;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate startDate;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate endDate;

    private AbsenceStatus status;
    private Long createdAt;
    private Long updatedAt;

    // No-arg constructor
    public Absence() {
    }

    // Full constructor
    public Absence(Long id, String childId, Long parentId, AbsenceType absenceType,
                   LocalDate startDate, LocalDate endDate, AbsenceStatus status,
                   Long createdAt, Long updatedAt) {
        this.id = id;
        this.childId = childId;
        this.parentId = parentId;
        this.absenceType = absenceType;
        this.startDate = startDate;
        this.endDate = endDate;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Business logic methods
    public boolean isActive() {
        return status == AbsenceStatus.ACTIVE;
    }

    public boolean isCompleted() {
        return status == AbsenceStatus.COMPLETED;
    }

    public boolean isMultiDay() {
        return absenceType == AbsenceType.MULTIPLE_DAYS;
    }

    public long getDurationInDays() {
        if (startDate == null || endDate == null) {
            return 0;
        }
        return java.time.temporal.ChronoUnit.DAYS.between(startDate, endDate) + 1;
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

    public String getChildName() {
        return childName;
    }

    public void setChildName(String childName) {
        this.childName = childName;
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

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }

    public Long getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Long updatedAt) {
        this.updatedAt = updatedAt;
    }
}
