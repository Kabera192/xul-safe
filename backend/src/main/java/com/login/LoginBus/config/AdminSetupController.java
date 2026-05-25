package com.login.LoginBus.config;

import com.login.LoginBus.accounts.app.AccountsPublicService;
import com.login.LoginBus.accounts.domain.User;
import com.login.LoginBus.accounts.domain.UserRole;
import com.login.LoginBus.accounts.infra.UserJpaEntity;
import com.login.LoginBus.accounts.infra.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * One-time admin setup endpoint.
 *
 * Protected by a setup key read from the ADMIN_SETUP_KEY environment variable.
 * Permanently disables itself once an ADMIN user exists in the database.
 *
 * Usage:
 *   1. Set environment variable:  ADMIN_SETUP_KEY=your-secret-key
 *   2. POST /api/v1/admin/setup  with JSON body:
 *      { "setupKey": "your-secret-key", "email": "...", "password": "...",
 *        "firstName": "...", "lastName": "...", "phoneNumber": "..." }
 *   3. After the admin is created, unset ADMIN_SETUP_KEY (endpoint becomes permanently disabled).
 */
@RestController
@RequestMapping("/api/v1/admin/setup")
@CrossOrigin(origins = "*")
public class AdminSetupController {

    @Value("${admin.setup.key:}")
    private String setupKey;

    private final AccountsPublicService accountsService;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminSetupController(AccountsPublicService accountsService,
                                UserRepository userRepository,
                                PasswordEncoder passwordEncoder) {
        this.accountsService = accountsService;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @PostMapping
    public ResponseEntity<Map<String, String>> setup(@RequestBody AdminSetupRequest request) {

        // Endpoint is disabled if no setup key is configured
        if (setupKey == null || setupKey.isBlank()) {
            return ResponseEntity.status(503)
                    .body(Map.of("message", "Admin setup is disabled. Set the ADMIN_SETUP_KEY environment variable to enable it."));
        }

        // Validate setup key — constant-time comparison to prevent timing attacks
        if (!constantTimeEquals(setupKey, request.setupKey())) {
            return ResponseEntity.status(403)
                    .body(Map.of("message", "Invalid setup key."));
        }

        // Self-disable: once an admin exists, this endpoint can never create another via setup
        if (userRepository.existsByRole(UserRole.ADMIN)) {
            return ResponseEntity.status(409)
                    .body(Map.of("message", "An admin account already exists. This endpoint is permanently disabled."));
        }

        // Validate required fields
        if (request.email() == null || request.email().isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Email is required."));
        }
        if (request.password() == null || request.password().length() < 8) {
            return ResponseEntity.badRequest().body(Map.of("message", "Password must be at least 8 characters."));
        }
        if (accountsService.userExists(request.email().trim().toLowerCase())) {
            return ResponseEntity.status(409).body(Map.of("message", "A user with that email already exists."));
        }

        User admin = new User();
        admin.setFirstName(request.firstName() != null && !request.firstName().isBlank() ? request.firstName() : "Admin");
        admin.setLastName(request.lastName() != null && !request.lastName().isBlank() ? request.lastName() : "User");
        admin.setEmail(request.email().trim().toLowerCase());
        admin.setPassword(passwordEncoder.encode(request.password()));
        admin.setPhoneNumber(request.phoneNumber() != null && !request.phoneNumber().isBlank() ? request.phoneNumber() : "0000000000");
        admin.setRole(UserRole.ADMIN);

        accountsService.createUser(admin);

        return ResponseEntity.ok(Map.of("message", "Admin account created successfully. Unset ADMIN_SETUP_KEY to seal this endpoint."));
    }

    /** Constant-time string comparison to prevent timing-based attacks on the setup key. */
    private boolean constantTimeEquals(String a, String b) {
        if (a == null || b == null) return false;
        if (a.length() != b.length()) return false;
        int diff = 0;
        for (int i = 0; i < a.length(); i++) {
            diff |= a.charAt(i) ^ b.charAt(i);
        }
        return diff == 0;
    }

    /**
     * Reset the existing admin password — useful when the stored password is not bcrypt-hashed.
     * POST /api/v1/admin/setup/reset-password
     * Body: { "setupKey": "...", "email": "...", "newPassword": "..." }
     */
    @PostMapping("/reset-password")
    public ResponseEntity<Map<String, String>> resetPassword(@RequestBody AdminPasswordResetRequest request) {

        if (setupKey == null || setupKey.isBlank()) {
            return ResponseEntity.status(503)
                    .body(Map.of("message", "Admin setup is disabled. Set the ADMIN_SETUP_KEY environment variable to enable it."));
        }

        if (!constantTimeEquals(setupKey, request.setupKey())) {
            return ResponseEntity.status(403)
                    .body(Map.of("message", "Invalid setup key."));
        }

        if (request.email() == null || request.email().isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Email is required."));
        }
        if (request.newPassword() == null || request.newPassword().length() < 8) {
            return ResponseEntity.badRequest().body(Map.of("message", "New password must be at least 8 characters."));
        }

        UserJpaEntity admin = userRepository.findByEmail(request.email().trim().toLowerCase())
                .orElse(null);

        if (admin == null || admin.getRole() != UserRole.ADMIN) {
            return ResponseEntity.status(404)
                    .body(Map.of("message", "No admin account found with that email."));
        }

        admin.setPassword(passwordEncoder.encode(request.newPassword()));
        userRepository.save(admin);

        return ResponseEntity.ok(Map.of("message", "Admin password updated successfully. Unset ADMIN_SETUP_KEY now."));
    }

    public record AdminSetupRequest(
            String setupKey,
            String email,
            String password,
            String firstName,
            String lastName,
            String phoneNumber
    ) {}

    public record AdminPasswordResetRequest(
            String setupKey,
            String email,
            String newPassword
    ) {}
}
