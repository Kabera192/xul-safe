package com.login.LoginBus.students.app;

import com.login.LoginBus.students.domain.Child;
import java.util.List;

/**
 * Public service interface for Students module.
 * Other modules use this interface to access child information.
 *
 * This is the ONLY way other modules should interact with the students module.
 */
public interface StudentsPublicService {

    /**
     * Get all children for a parent.
     *
     * @param parentId The parent ID
     * @return List of children
     */
    List<Child> getChildrenForParent(Long parentId);

    /**
     * Get a specific child by ID.
     *
     * @param childId The child ID
     * @return The child, or null if not found
     */
    Child getChildById(String childId);

    /**
     * Check if a child exists.
     *
     * @param childId The child ID
     * @return true if exists, false otherwise
     */
    boolean childExists(String childId);

    /**
     * Assign a bus stop to a child.
     *
     * @param childId   The child ID
     * @param busStopId The bus stop ID
     */
    void assignBusStop(String childId, String busStopId);
}
