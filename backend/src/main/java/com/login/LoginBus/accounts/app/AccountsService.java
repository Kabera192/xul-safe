package com.login.LoginBus.accounts.app;

import com.login.LoginBus.accounts.domain.Conductor;
import com.login.LoginBus.accounts.domain.EmergencyContact;
import com.login.LoginBus.accounts.domain.User;

import java.util.List;

/**
 * Service interface for Accounts module.
 * Defines all business operations for users, parents, and conductors.
 */
public interface AccountsService {

    // ========== User Operations ==========

    /**
     * Get user by ID.
     *
     * @param userId The user ID
     * @return The user, or null if not found
     */
    User getUserById(Long userId);

    /**
     * Get user by email.
     *
     * @param email The email address
     * @return The user, or null if not found
     */
    User getUserByEmail(String email);

    /**
     * Create a new user.
     *
     * @param user The user to create
     * @return The created user
     */
    User createUser(User user);

    /**
     * Update an existing user.
     *
     * @param userId The user ID
     * @param user The updated user data
     * @return The updated user
     */
    User updateUser(Long userId, User user);

    /**
     * Check if user exists.
     *
     * @param userId The user ID
     * @return true if exists, false otherwise
     */
    boolean userExists(Long userId);

    /**
     * Check if email is already registered.
     *
     * @param email The email address
     * @return true if exists, false otherwise
     */
    boolean emailExists(String email);

    // ========== Conductor Operations ==========

    /**
     * Get conductor by ID.
     *
     * @param conductorId The conductor ID
     * @return The conductor, or null if not found
     */
    Conductor getConductorById(Long conductorId);

    /**
     * Get all active conductors.
     *
     * @return List of active conductors
     */
    List<Conductor> getActiveConductors();

    /**
     * Get all conductors.
     *
     * @return List of conductors
     */
    List<Conductor> getAllConductors();

    /**
     * Create a new conductor.
     *
     * @param conductor The conductor to create
     * @return The created conductor
     */
    Conductor createConductor(Conductor conductor);

    /**
     * Update an existing conductor.
     *
     * @param conductorId The conductor ID
     * @param conductor The updated conductor data
     * @return The updated conductor
     */
    Conductor updateConductor(Long conductorId, Conductor conductor);

    /**
     * Delete a conductor.
     *
     * @param conductorId The conductor ID
     */
    void deleteConductor(Long conductorId);

    // ========== Emergency Contact Operations ==========

    /**
     * Get all emergency contacts for a parent.
     *
     * @param parentId The parent ID
     * @return List of emergency contacts
     */
    List<EmergencyContact> getEmergencyContactsByParent(Long parentId);

    /**
     * Create a new emergency contact.
     *
     * @param contact The contact to create
     * @return The created contact
     */
    EmergencyContact createEmergencyContact(EmergencyContact contact);

    /**
     * Update an existing emergency contact.
     *
     * @param contactId The contact ID
     * @param contact The updated contact data
     * @return The updated contact
     */
    EmergencyContact updateEmergencyContact(Long contactId, EmergencyContact contact);

    /**
     * Delete an emergency contact.
     *
     * @param parentId The parent ID
     * @param contactId The contact ID
     */
    void deleteEmergencyContact(Long parentId, Long contactId);
}
