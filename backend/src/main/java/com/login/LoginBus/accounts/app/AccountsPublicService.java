package com.login.LoginBus.accounts.app;

import com.login.LoginBus.accounts.domain.User;
import com.login.LoginBus.accounts.domain.Parent;
import com.login.LoginBus.accounts.domain.Conductor;

/**
 * Public service interface for Accounts module.
 * Other modules use this interface to access user, parent, and conductor information.
 *
 * This is the ONLY way other modules should interact with the accounts module.
 */
public interface AccountsPublicService {

    /**
     * Get user by ID.
     *
     * @param userId The user ID
     * @return The user, or null if not found
     */
    User getUserById(Long userId);

    /**
     * Get parent by ID.
     *
     * @param parentId The parent ID
     * @return The parent, or null if not found
     */
    Parent getParentById(Long parentId);

    /**
     * Get parent by user ID.
     *
     * @param userId The user ID
     * @return The parent, or null if not found
     */
    Parent getParentByUserId(Long userId);

    /**
     * Get conductor by ID.
     *
     * @param conductorId The conductor ID
     * @return The conductor, or null if not found
     */
    Conductor getConductorById(Long conductorId);

    /**
     * Check if a user exists by ID.
     *
     * @param userId The user ID
     * @return true if exists, false otherwise
     */
    boolean userExists(Long userId);

    /**
     * Check if a user exists by email.
     *
     * @param email The user email
     * @return true if exists, false otherwise
     */
    boolean userExists(String email);

    /**
     * Get user by email.
     *
     * @param email The user email
     * @return The user, or null if not found
     */
    User getUserByEmail(String email);

    /**
     * Create a new user.
     *
     * @param user The user to create
     * @return The created user with generated ID
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
}
