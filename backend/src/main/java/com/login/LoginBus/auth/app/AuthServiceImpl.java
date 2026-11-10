package com.login.LoginBus.auth.app;

import com.login.LoginBus.accounts.app.AccountsPublicService;
import com.login.LoginBus.accounts.domain.User;
import com.login.LoginBus.accounts.domain.UserRole;
import com.login.LoginBus.accounts.infra.UserJpaEntity;
import com.login.LoginBus.accounts.infra.UserRepository;
import com.login.LoginBus.auth.domain.AuthResponse;
import com.login.LoginBus.notifications.app.NotificationsPublicService;
import com.login.LoginBus.notifications.domain.NotificationCategory;
import com.login.LoginBus.notifications.domain.NotificationType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.security.SecureRandom;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class AuthServiceImpl implements AuthService, AuthPublicService {

    private final AccountsPublicService accountsService;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final EmailService emailService;
    private final NotificationsPublicService notificationsPublicService;
    private final TransactionTemplate requiresNewTransactionTemplate;

    private static final String UPLOAD_DIR = "uploads/profile-photos/";
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
    private static final long OTP_VALIDITY_MS = 10 * 60 * 1000; // 10 minutes
    private static final int MAX_OTP_ATTEMPTS = 5;

    public AuthServiceImpl(AccountsPublicService accountsService,
                           UserRepository userRepository,
                           PasswordEncoder passwordEncoder,
                           JwtService jwtService,
                           EmailService emailService,
                           NotificationsPublicService notificationsPublicService,
                           PlatformTransactionManager transactionManager) {
        this.accountsService = accountsService;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.emailService = emailService;
        this.notificationsPublicService = notificationsPublicService;
        this.requiresNewTransactionTemplate = new TransactionTemplate(transactionManager);
        this.requiresNewTransactionTemplate.setPropagationBehavior(Propagation.REQUIRES_NEW.value());
    }

    @Override
    @Transactional
    public void registerUser(User user) {
        if (!isValidEmail(user.getEmail())) {
            throw new IllegalArgumentException("Invalid email format");
        }
        if (!isStrongPassword(user.getPassword())) {
            throw new IllegalArgumentException("Password must be at least 8 characters, contain no spaces, and include at least one number");
        }
        Optional<UserJpaEntity> existing = userRepository.findByEmail(normalizeEmail(user.getEmail()));
        if (existing.isPresent()) {
            UserJpaEntity existingEntity = existing.get();
            if (existingEntity.isEmailVerified()) {
                throw new IllegalArgumentException("Email already registered");
            }
            // An abandoned registration (closed the app, backed out, etc.)
            // before verifying — update their details in case they're
            // correcting something and resend the code, rather than leaving
            // them permanently stuck on "Email already registered".
            //
            // The password is deliberately NOT touched here: this endpoint is
            // unauthenticated, so anyone can "re-register" an email they
            // don't own. Resetting the password on this path would let an
            // attacker set a password the real owner would then unknowingly
            // verify (by entering the OTP sent to their own inbox). Only an
            // OTP-verified flow may change credentials for an existing account.
            existingEntity.setFirstName(user.getFirstName());
            existingEntity.setLastName(user.getLastName());
            existingEntity.setPhoneNumber(user.getPhoneNumber());
            userRepository.save(existingEntity);
            sendOtpToUser(existingEntity, "Account verification");
            return;
        }

        // Hash password before storing
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        // Account isn't active until the registration OTP is verified.
        user.setEmailVerified(false);

        User createdUser = accountsService.createUser(user);

        UserJpaEntity userEntity = userRepository.findByEmail(createdUser.getEmail()).orElseThrow();
        sendOtpToUser(userEntity, "Account verification");
    }

    @Override
    @Transactional
    public void resendRegistrationOtp(String email) {
        UserJpaEntity user = userRepository.findByEmail(normalizeEmail(email))
                .orElseThrow(() -> new IllegalArgumentException("No account found with this email"));

        if (user.isEmailVerified()) {
            throw new IllegalStateException("This account is already verified");
        }

        sendOtpToUser(user, "Account verification");
    }

    @Override
    @Transactional
    public AuthResponse verifyRegistrationOtp(String email, String otp) {
        UserJpaEntity user = userRepository.findByEmail(normalizeEmail(email))
                .orElseThrow(() -> new IllegalArgumentException("No account found with this email"));

        checkOtp(user, otp);

        user.setEmailVerified(true);
        user.setOtpCode(null);
        user.setOtpExpiresAt(null);
        userRepository.save(user);

        notifyAdminsAccountVerified(user);

        JwtService.TokenPair pair = jwtService.issueTokens(user);
        return buildAuthResponse(pair);
    }

    private void notifyAdminsAccountVerified(UserJpaEntity user) {
        if (user.getRole() != UserRole.PARENT) return;

        try {
            List<Long> adminIds = accountsService.getUsersByRole(UserRole.ADMIN)
                    .stream()
                    .map(User::getId)
                    .filter(java.util.Objects::nonNull)
                    .collect(java.util.stream.Collectors.toList());
            if (adminIds.isEmpty()) return;

            notificationsPublicService.sendNotificationToUsers(
                    adminIds,
                    user.getId(),
                    NotificationType.INFO,
                    NotificationCategory.PARENT_REGISTERED,
                    "New parent registered",
                    user.getFirstName() + " " + user.getLastName() + " verified their account and joined as a parent."
            );
        } catch (Exception e) {
            // Don't fail account verification if notification delivery fails
        }
    }

    @Override
    @Transactional(readOnly = true)
    public AuthResponse authenticateUser(String email, String password) {
        UserJpaEntity userEntity = userRepository.findByEmail(email.trim().toLowerCase())
                .orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));

        if (!passwordEncoder.matches(password, userEntity.getPassword())) {
            throw new IllegalArgumentException("Invalid email or password");
        }

        if (!userEntity.isEmailVerified()) {
            throw new IllegalStateException("Please verify your email before logging in");
        }

        UserRole role = userEntity.getRole();
        if (role == null) {
            throw new IllegalArgumentException("Access denied for this account type.");
        }

        JwtService.TokenPair pair = jwtService.issueTokens(userEntity);
        return buildAuthResponse(pair);
    }

    @Override
    public AuthResponse refreshTokens(String refreshToken) {
        JwtService.TokenPair pair = jwtService.refresh(refreshToken);
        return buildAuthResponse(pair);
    }

    @Override
    public boolean userExists(String email) {
        return accountsService.userExists(email);
    }

    @Override
    @Transactional
    public void updatePassword(Long userId, String currentPassword, String newPassword) {
        UserJpaEntity userEntity = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (!passwordEncoder.matches(currentPassword, userEntity.getPassword())) {
            throw new IllegalArgumentException("Current password is incorrect");
        }
        if (!isStrongPassword(newPassword)) {
            throw new IllegalArgumentException("Password must be at least 8 characters, contain no spaces, and include at least one number");
        }

        userEntity.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(userEntity);
    }

    @Override
    public String uploadProfilePhoto(Long userId, MultipartFile file) {
        UserJpaEntity userEntity = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (file.isEmpty()) throw new IllegalArgumentException("File is empty");
        if (file.getSize() > MAX_FILE_SIZE) throw new IllegalArgumentException("File size exceeds 5MB limit");

        String contentType = file.getContentType();
        if (contentType == null || !isValidImageType(contentType)) {
            throw new IllegalArgumentException("Invalid file type. Only jpg, png, gif allowed");
        }

        try {
            File uploadDirFile = new File(UPLOAD_DIR);
            if (!uploadDirFile.exists()) uploadDirFile.mkdirs();

            String originalFilename = file.getOriginalFilename();
            String extension = (originalFilename != null && originalFilename.contains("."))
                    ? originalFilename.substring(originalFilename.lastIndexOf(".")) : ".jpg";
            String filename = UUID.randomUUID() + extension;

            Path filePath = Paths.get(UPLOAD_DIR + filename);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            String photoUrl = "/" + UPLOAD_DIR + filename;
            userEntity.setPhotoUrl(photoUrl);
            userRepository.save(userEntity);

            return photoUrl;
        } catch (IOException e) {
            throw new RuntimeException("Failed to upload file: " + e.getMessage());
        }
    }

    @Override
    public boolean isValidEmail(String email) {
        if (email == null) return false;
        return email.matches("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");
    }

    @Override
    public boolean isStrongPassword(String password) {
        if (password == null || password.length() < 8) return false;
        if (password.contains(" ")) return false;
        if (!password.matches(".*[0-9].*")) return false;
        return true;
    }

    @Override
    @Transactional
    public void sendPasswordResetOtp(String email) {
        // Deliberately a no-op (not an error) when the email isn't registered —
        // the caller gets the same response either way, so this endpoint can't
        // be used to probe which emails have an account.
        userRepository.findByEmail(normalizeEmail(email))
                .ifPresent(user -> sendOtpToUser(user, "Password reset"));
    }

    @Override
    @Transactional
    public void verifyOtp(String email, String otp) {
        UserJpaEntity user = userRepository.findByEmail(normalizeEmail(email))
                .orElseThrow(() -> new IllegalArgumentException("No account found with this email"));

        checkOtp(user, otp);
    }

    @Override
    @Transactional
    public void resetPassword(String email, String otp, String newPassword) {
        verifyOtp(email, otp);

        UserJpaEntity user = userRepository.findByEmail(normalizeEmail(email)).orElseThrow();

        if (!isStrongPassword(newPassword)) {
            throw new IllegalArgumentException("Password must be at least 8 characters, contain no spaces, and include at least one number");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        user.setOtpCode(null);
        user.setOtpExpiresAt(null);
        userRepository.save(user);
    }

    private String normalizeEmail(String email) {
        return email == null ? "" : email.trim().toLowerCase();
    }

    private void sendOtpToUser(UserJpaEntity user, String purpose) {
        String otp = String.format("%06d", new SecureRandom().nextInt(1_000_000));
        user.setOtpCode(otp);
        user.setOtpExpiresAt(System.currentTimeMillis() + OTP_VALIDITY_MS);
        user.setOtpAttempts(0);
        userRepository.save(user);

        emailService.sendOtp(user.getEmail(), otp, purpose);
    }

    /**
     * Caller must run in a writable transaction — this persists the
     * attempt counter on every call, not just on success, so repeated
     * wrong guesses against the same code get locked out rather than
     * being retried indefinitely within its validity window.
     */
    private void checkOtp(UserJpaEntity user, String otp) {
        if (user.getOtpCode() == null) {
            throw new IllegalArgumentException("Invalid OTP code");
        }
        if (user.getOtpExpiresAt() == null || System.currentTimeMillis() > user.getOtpExpiresAt()) {
            throw new IllegalArgumentException("OTP has expired. Please request a new one.");
        }
        if (user.getOtpAttempts() >= MAX_OTP_ATTEMPTS) {
            throw new IllegalArgumentException("Too many incorrect attempts. Please request a new code.");
        }
        if (!user.getOtpCode().equals(otp == null ? "" : otp.trim())) {
            // Persisted in its own transaction (REQUIRES_NEW) so the increment
            // survives the exception below rolling back the caller's
            // transaction — otherwise the attempt counter never commits and
            // the lockout above never triggers.
            int attemptsSoFar = user.getOtpAttempts();
            Long userId = user.getId();
            requiresNewTransactionTemplate.executeWithoutResult(status -> {
                userRepository.findById(userId).ifPresent(managed -> {
                    managed.setOtpAttempts(attemptsSoFar + 1);
                    userRepository.save(managed);
                });
            });
            throw new IllegalArgumentException("Invalid OTP code");
        }
        user.setOtpAttempts(0);
    }

    // AuthPublicService methods

    @Override
    public boolean validateToken(String token) {
        return token != null && !token.isBlank();
    }

    @Override
    public Long getUserIdFromToken(String token) {
        return null; // Handled by Spring Security JWT filter
    }

    @Override
    public boolean hasRole(Long userId, String role) {
        return userRepository.findById(userId)
                .map(u -> u.getRole() != null && role.equals(u.getRole().name()))
                .orElse(false);
    }

    private AuthResponse buildAuthResponse(JwtService.TokenPair pair) {
        return new AuthResponse(
                pair.accessToken(),
                pair.accessExpiresAt(),
                pair.refreshToken(),
                pair.refreshExpiresAt(),
                new AuthResponse.UserInfo(pair.userId(), pair.roles())
        );
    }

    private boolean isValidImageType(String contentType) {
        return contentType.equals("image/jpeg") || contentType.equals("image/jpg")
                || contentType.equals("image/png") || contentType.equals("image/gif");
    }
}
