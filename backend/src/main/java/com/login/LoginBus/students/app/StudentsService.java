package com.login.LoginBus.students.app;

import com.login.LoginBus.students.domain.Absence;
import com.login.LoginBus.students.domain.Child;
import com.login.LoginBus.students.infra.ChildJpaEntity;

import java.util.List;

/**
 * Service interface for Students module.
 * Defines all business operations for children and absences.
 */
public interface StudentsService {

    // ========== Child Operations ==========

    /**
     * Get all children for a parent.
     *
     * @param parentId The parent ID
     * @return List of children
     */
    List<Child> getChildrenForParent(Long parentId);

    /**
     * Get all children (admin endpoint).
     *
     * @return List of children
     */
    List<Child> getAllChildren();

    /**
     * Get a specific child by ID.
     *
     * @param childId The child ID
     * @return The child, or null if not found
     */
    Child getChildById(String childId);

    /**
     * Create a new child.
     *
     * @param child The child to create
     * @return The created child
     */
    Child createChild(Child child);

    /**
     * Update an existing child.
     *
     * @param childId The child ID
     * @param child The updated child data
     * @return The updated child
     */
    Child updateChild(String childId, Child child);

    /**
     * Delete a child.
     *
     * @param childId The child ID
     */
    void deleteChild(String childId);

    /**
     * Check if a child exists.
     *
     * @param childId The child ID
     * @return true if exists, false otherwise
     */
    boolean childExists(String childId);

    // ========== Absence Operations ==========

    /**
     * Get all absences across all children (admin).
     *
     * @return List of all absences enriched with child name
     */
    List<Absence> getAllAbsences();

    /**
     * Get all absences for a child.
     *
     * @param childId The child ID
     * @return List of absences
     */
    List<Absence> getAbsencesForChild(String childId);

    /**
     * Get all absences for a parent.
     *
     * @param parentId The parent ID
     * @return List of absences
     */
    List<Absence> getAbsencesForParent(Long parentId);

    /**
     * Get active absences for a parent.
     *
     * @param parentId The parent ID
     * @return List of active absences
     */
    List<Absence> getActiveAbsencesForParent(Long parentId);

    /**
     * Create a new absence.
     *
     * @param absence The absence to create
     * @return The created absence
     */
    Absence createAbsence(Absence absence);

    /**
     * Update an existing absence.
     *
     * @param absenceId The absence ID
     * @param absence The updated absence data
     * @return The updated absence
     */
    Absence updateAbsence(Long absenceId, Absence absence);

    /**
     * Delete an absence.
     *
     * @param absenceId The absence ID
     */
    void deleteAbsence(Long absenceId);

    /**
     * Complete an absence (mark as completed early).
     *
     * @param absenceId The absence ID
     * @return The completed absence
     */
    Absence completeAbsence(Long absenceId);

}
