package com.login.LoginBus.auth.app;

import com.login.LoginBus.accounts.app.AccountsPublicService;
import com.login.LoginBus.accounts.domain.User;
import com.login.LoginBus.accounts.domain.UserRole;
import com.login.LoginBus.accounts.infra.UserJpaEntity;
import com.login.LoginBus.accounts.infra.UserRepository;
import com.login.LoginBus.auth.domain.AuthResponse;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
public class AuthServiceImpl implements AuthService, AuthPublicService {

    private final AccountsPublicService accountsService;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    private static final String UPLOAD_DIR = "uploads/profile-photos/";
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB

    public AuthServiceImpl(AccountsPublicService accountsService,
                           UserRepository userRepository,
                           PasswordEncoder passwordEncoder,
                           JwtService jwtService) {
        this.accountsService = accountsService;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Override
    @Transactional
    public AuthResponse registerUser(User user) {
        if (!isValidEmail(user.getEmail())) {
            throw new IllegalArgumentException("Invalid email format");
        }
        if (!isStrongPassword(user.getPassword())) {
            throw new IllegalArgumentException("Password must be at least 8 characters with uppercase, lowercase, and number");
        }
        if (accountsService.userExists(user.getEmail())) {
            throw new IllegalArgumentException("Email already registered");
        }

        // Hash password before storing
        user.setPassword(passwordEncoder.encode(user.getPassword()));

        User createdUser = accountsService.createUser(user);

        UserJpaEntity userEntity = userRepository.findByEmail(createdUser.getEmail()).orElseThrow();
        JwtService.TokenPair pair = jwtService.issueTokens(userEntity);

        return buildAuthResponse(pair);
    }

    @Override
    @Transactional(readOnly = true)
    public AuthResponse authenticateUser(String email, String password) {
        UserJpaEntity userEntity = userRepository.findByEmail(email.trim().toLowerCase())
                .orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));

        if (!passwordEncoder.matches(password, userEntity.getPassword())) {
            throw new IllegalArgumentException("Invalid email or password");
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
            throw new IllegalArgumentException("Password must be at least 8 characters with uppercase, lowercase, and number");
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
        if (!password.matches(".*[A-Z].*")) return false;
        if (!password.matches(".*[a-z].*")) return false;
        if (!password.matches(".*[0-9].*")) return false;
        return true;
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
