package com.login.LoginBus.auth.app;

import com.login.LoginBus.accounts.domain.User;
import com.login.LoginBus.auth.domain.AuthResponse;
import org.springframework.web.multipart.MultipartFile;

/**
 * Service interface for authentication operations (internal module use).
 */
public interface AuthService {

    void registerUser(User user);

    void resendRegistrationOtp(String email);

    AuthResponse verifyRegistrationOtp(String email, String otp);

    AuthResponse authenticateUser(String email, String password);

    AuthResponse refreshTokens(String refreshToken);

    boolean userExists(String email);

    void updatePassword(Long userId, String currentPassword, String newPassword);

    String uploadProfilePhoto(Long userId, MultipartFile file);

    boolean isValidEmail(String email);

    boolean isStrongPassword(String password);

    void sendPasswordResetOtp(String email);

    void verifyOtp(String email, String otp);

    void resetPassword(String email, String otp, String newPassword);
}

