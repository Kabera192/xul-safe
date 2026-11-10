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
     * Get all children assigned to a bus.
     *
     * @param busId The bus ID
     * @return List of children assigned to the bus
     */
    List<Child> getChildrenForBus(Long busId);

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
     * @param busStopId The predefined bus stop ID
     */
    void assignBusStop(String childId, String busStopId);

    /**
     * Assign a bus to a child directly (used when approving a route request
     * for a child who has no bus yet). Enforces the same capacity check as
     * the regular child-update path.
     *
     * @param childId The child ID
     * @param busId   The bus ID
     */
    void assignBus(String childId, Long busId);
}