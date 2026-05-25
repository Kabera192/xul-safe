package com.login.LoginBus.accounts.api;

import com.login.LoginBus.accounts.app.AccountsService;
import com.login.LoginBus.accounts.domain.User;
import com.login.LoginBus.shared.api.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * REST controller for user profile operations.
 * All endpoints use /api/v1 prefix for versioning.
 */
@RestController
@RequestMapping("/api/v1/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private AccountsService accountsService;

    /**
     * Get user profile by ID.
     * GET /api/v1/users/{userId}
     *
     * @param userId The user ID
     * @return User profile
     */
    @GetMapping("/{userId}")
    public ResponseEntity<ApiResponse<User>> getUserProfile(@PathVariable Long userId) {
        User user = accountsService.getUserById(userId);

        if (user == null) {
            throw new IllegalArgumentException("User not found with ID: " + userId);
        }

        return ResponseEntity.ok(new ApiResponse<>(
            "User profile retrieved successfully",
            user
        ));
    }

    /**
     * Update user profile.
     * PUT /api/v1/users/{userId}
     *
     * Request body:
     * {
     *   "firstName": "John",
     *   "lastName": "Doe",
     *   "phoneNumber": "123456789",
     *   "photoUrl": "https://..."
     * }
     *
     * @param userId The user ID
     * @param user Updated user data
     * @return Updated user
     */
    @PutMapping("/{userId}")
    public ResponseEntity<ApiResponse<User>> updateUserProfile(
            @PathVariable Long userId,
            @RequestBody User user) {

        User updatedUser = accountsService.updateUser(userId, user);

        return ResponseEntity.ok(new ApiResponse<>(
            "Profile updated successfully",
            updatedUser
        ));
    }
}
