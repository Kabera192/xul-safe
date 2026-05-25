package com.login.LoginBus.accounts.api;

import com.login.LoginBus.accounts.api.dto.ProfileResponse;
import com.login.LoginBus.accounts.api.dto.UpdateProfileRequest;
import com.login.LoginBus.accounts.app.ProfileService;
import com.login.LoginBus.shared.api.ApiResponse;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/profile")
@CrossOrigin(origins = "*")
public class ProfileController {

    private final ProfileService profileService;

    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    /**
     * GET /api/v1/profile/me
     * Returns the authenticated user's profile.
     */
    @GetMapping("/me")
    public ResponseEntity<ProfileResponse> getMyProfile(@AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(profileService.getMyProfile(jwt));
    }

    /**
     * PATCH /api/v1/profile/me
     * Updates name / phone number.
     */
    @PatchMapping("/me")
    public ResponseEntity<ProfileResponse> updateMyProfile(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody UpdateProfileRequest request) {
        return ResponseEntity.ok(profileService.updateMyProfile(jwt, request));
    }

    /**
     * PATCH /api/v1/profile/me/photo
     * Uploads a new profile photo.
     */
    @PatchMapping(value = "/me/photo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<String>> uploadPhoto(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam("file") MultipartFile file) {
        String url = profileService.uploadProfilePhoto(jwt, file);
        return ResponseEntity.ok(new ApiResponse<>("Profile photo updated", url));
    }

    /**
     * GET /api/v1/profile/me/photo
     * Returns the raw photo bytes.
     */
    @GetMapping("/me/photo")
    public ResponseEntity<byte[]> getPhoto(@AuthenticationPrincipal Jwt jwt) {
        byte[] data = profileService.getProfilePhoto(jwt);
        return ResponseEntity.ok()
                .contentType(MediaType.IMAGE_JPEG)
                .body(data);
    }
}
