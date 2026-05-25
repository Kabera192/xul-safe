package com.login.LoginBus.auth.app;

/**
 * Public service interface for Auth module.
 * Other modules use this interface to access auth functionality.
 *
 * This is the ONLY way other modules should interact with the auth module.
 */
public interface AuthPublicService {

    /**
     * Validate if a token is valid and not expired.
     *
     * @param token The authentication token
     * @return true if valid, false otherwise
     */
    boolean validateToken(String token);

    /**
     * Extract the user ID from a valid token.
     *
     * @param token The authentication token
     * @return The user ID, or null if token is invalid
     */
    Long getUserIdFromToken(String token);

    /**
     * Check if a user has a specific role.
     *
     * @param userId The user ID
     * @param role The role to check
     * @return true if user has the role, false otherwise
     */
    boolean hasRole(Long userId, String role);
}
