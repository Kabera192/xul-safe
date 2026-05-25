package com.login.LoginBus.auth.api;

import com.login.LoginBus.accounts.domain.User;
import com.login.LoginBus.auth.app.AuthService;
import com.login.LoginBus.auth.domain.AuthResponse;
import com.login.LoginBus.auth.domain.LoginRequest;
import com.login.LoginBus.auth.domain.PasswordUpdateRequest;
import com.login.LoginBus.shared.api.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /**
     * Register a new user.
     * POST /api/v1/auth/register
     */
    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody User user) {
        if (user.getFirstName() == null || user.getFirstName().trim().isEmpty())
            throw new IllegalArgumentException("First name is required");
        if (user.getLastName() == null || user.getLastName().trim().isEmpty())
            throw new IllegalArgumentException("Last name is required");
        if (user.getEmail() == null || user.getEmail().trim().isEmpty())
            throw new IllegalArgumentException("Email is required");
        if (user.getPassword() == null || user.getPassword().trim().isEmpty())
            throw new IllegalArgumentException("Password is required");
        if (user.getPhoneNumber() == null || user.getPhoneNumber().trim().isEmpty())
            throw new IllegalArgumentException("Phone number is required");

        AuthResponse response = authService.registerUser(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * Login user.
     * POST /api/v1/auth/login
     * Returns tokens directly (no ApiResponse wrapper) for Flutter app compatibility.
     */
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest loginRequest) {
        if (loginRequest.getEmail() == null || loginRequest.getEmail().trim().isEmpty())
            throw new IllegalArgumentException("Email is required");
        if (loginRequest.getPassword() == null || loginRequest.getPassword().trim().isEmpty())
            throw new IllegalArgumentException("Password is required");

        AuthResponse response = authService.authenticateUser(
                loginRequest.getEmail().trim().toLowerCase(),
                loginRequest.getPassword()
        );
        return ResponseEntity.ok(response);
    }

    /**
     * Refresh access token.
     * POST /api/v1/auth/refresh
     */
    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refresh(@RequestBody Map<String, String> body) {
        String refreshToken = body.get("refresh_token");
        if (refreshToken == null || refreshToken.trim().isEmpty())
            throw new IllegalArgumentException("refresh_token is required");

        AuthResponse response = authService.refreshTokens(refreshToken.trim());
        return ResponseEntity.ok(response);
    }

    /**
     * Update user password.
     * PUT /api/v1/auth/{userId}/password
     */
    @PutMapping("/{userId}/password")
    public ResponseEntity<ApiResponse<Void>> updatePassword(
            @PathVariable Long userId,
            @RequestBody PasswordUpdateRequest request) {
        if (request.getCurrentPassword() == null || request.getCurrentPassword().trim().isEmpty())
            throw new IllegalArgumentException("Current password is required");
        if (request.getNewPassword() == null || request.getNewPassword().trim().isEmpty())
            throw new IllegalArgumentException("New password is required");

        authService.updatePassword(userId, request.getCurrentPassword(), request.getNewPassword());
        return ResponseEntity.ok(new ApiResponse<>("Password updated successfully", null));
    }

    /**
     * Upload profile photo.
     * POST /api/v1/auth/{userId}/photo
     */
    @PostMapping("/{userId}/photo")
    public ResponseEntity<ApiResponse<String>> uploadProfilePhoto(
            @PathVariable Long userId,
            @RequestParam("file") MultipartFile file) {
        String photoUrl = authService.uploadProfilePhoto(userId, file);
        return ResponseEntity.ok(new ApiResponse<>("Profile photo uploaded successfully", photoUrl));
    }

    /**
     * Check if email exists.
     * GET /api/v1/auth/check-email?email=xxx
     */
    @GetMapping("/check-email")
    public ResponseEntity<ApiResponse<Boolean>> checkEmailExists(@RequestParam String email) {
        boolean exists = authService.userExists(email);
        return ResponseEntity.ok(new ApiResponse<>(
                exists ? "Email is already registered" : "Email is available", exists));
    }
}
