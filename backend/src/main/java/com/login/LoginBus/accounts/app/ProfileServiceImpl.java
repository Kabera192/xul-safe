package com.login.LoginBus.accounts.app;

import com.login.LoginBus.accounts.api.dto.ProfileResponse;
import com.login.LoginBus.accounts.api.dto.UpdateProfileRequest;
import com.login.LoginBus.accounts.infra.ConductorJpaEntity;
import com.login.LoginBus.accounts.infra.ConductorRepository;
import com.login.LoginBus.accounts.infra.ParentJpaEntity;
import com.login.LoginBus.accounts.infra.ParentRepository;
import com.login.LoginBus.accounts.infra.UserJpaEntity;
import com.login.LoginBus.accounts.infra.UserRepository;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class ProfileServiceImpl implements ProfileService {

    private final UserRepository userRepository;
    private final ConductorRepository conductorRepository;
    private final ParentRepository parentRepository;

    private static final String UPLOAD_DIR = "uploads/profile-photos/";
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024;

    public ProfileServiceImpl(UserRepository userRepository,
                               ConductorRepository conductorRepository,
                               ParentRepository parentRepository) {
        this.userRepository = userRepository;
        this.conductorRepository = conductorRepository;
        this.parentRepository = parentRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public ProfileResponse getMyProfile(Jwt jwt) {
        UserJpaEntity user = resolveUser(jwt);
        Long profileId = resolveProfileId(user);
        return toResponse(user, profileId);
    }

    @Override
    @Transactional
    public ProfileResponse updateMyProfile(Jwt jwt, UpdateProfileRequest request) {
        UserJpaEntity user = resolveUser(jwt);

        if (request.getFirstName() != null && !request.getFirstName().isBlank()) {
            user.setFirstName(request.getFirstName().trim());
        }
        if (request.getLastName() != null && !request.getLastName().isBlank()) {
            user.setLastName(request.getLastName().trim());
        }
        if (request.getPhoneNumber() != null && !request.getPhoneNumber().isBlank()) {
            user.setPhoneNumber(request.getPhoneNumber().trim());
        }
        if (request.getEmail() != null && !request.getEmail().isBlank()) {
            user.setEmail(request.getEmail().trim().toLowerCase());
        }
        userRepository.save(user);

        Long profileId = resolveProfileId(user);
        return toResponse(user, profileId);
    }

    @Override
    @Transactional
    public String uploadProfilePhoto(Jwt jwt, MultipartFile file) {
        UserJpaEntity user = resolveUser(jwt);

        if (file.isEmpty()) throw new IllegalArgumentException("File is empty");
        if (file.getSize() > MAX_FILE_SIZE) throw new IllegalArgumentException("File size exceeds 5MB");

        String contentType = file.getContentType();
        if (contentType == null || (!contentType.startsWith("image/"))) {
            throw new IllegalArgumentException("Invalid file type");
        }

        try {
            File dir = new File(UPLOAD_DIR);
            if (!dir.exists()) dir.mkdirs();

            String original = file.getOriginalFilename();
            String ext = (original != null && original.contains("."))
                    ? original.substring(original.lastIndexOf(".")) : ".jpg";
            String filename = UUID.randomUUID() + ext;
            Path dest = Paths.get(UPLOAD_DIR + filename);
            Files.copy(file.getInputStream(), dest, StandardCopyOption.REPLACE_EXISTING);

            String photoUrl = "/" + UPLOAD_DIR + filename;
            user.setPhotoUrl(photoUrl);
            userRepository.save(user);
            return photoUrl;
        } catch (IOException e) {
            throw new RuntimeException("Failed to upload photo: " + e.getMessage());
        }
    }

    @Override
    public byte[] getProfilePhoto(Jwt jwt) {
        UserJpaEntity user = resolveUser(jwt);
        String photoUrl = user.getPhotoUrl();
        if (photoUrl == null || photoUrl.isBlank()) {
            throw new IllegalStateException("No profile photo set");
        }
        String relativePath = photoUrl.startsWith("/") ? photoUrl.substring(1) : photoUrl;
        try {
            return Files.readAllBytes(Paths.get(relativePath));
        } catch (IOException e) {
            throw new RuntimeException("Photo not found: " + e.getMessage());
        }
    }

    // ── helpers ────────────────────────────────────────────────────────────────

    private UserJpaEntity resolveUser(Jwt jwt) {
        Long userId = jwt.getClaim("user_id");
        if (userId == null) throw new IllegalArgumentException("Invalid token: missing user_id");
        return userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
    }

    private Long resolveProfileId(UserJpaEntity user) {
        String role = user.getRole() != null ? user.getRole().name() : "";
        return switch (role) {
            case "DRIVER", "CONDUCTOR" -> conductorRepository.findByUserId(user.getId())
                    .map(ConductorJpaEntity::getId).orElse(null);
            case "PARENT" -> parentRepository.findByUserId(user.getId())
                    .map(ParentJpaEntity::getId).orElse(null);
            default -> null;
        };
    }

    private ProfileResponse toResponse(UserJpaEntity user, Long profileId) {
        List<String> roles = user.getRole() != null ? List.of(user.getRole().name()) : List.of();
        return new ProfileResponse(
                user.getId(),
                user.getFirstName(),
                user.getLastName(),
                user.getEmail(),
                user.getPhoneNumber(),
                user.getPhotoUrl(),
                roles,
                profileId
        );
    }
}
