package com.login.LoginBus.accounts.app;

import com.login.LoginBus.accounts.api.dto.ProfileResponse;
import com.login.LoginBus.accounts.api.dto.UpdateProfileRequest;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.multipart.MultipartFile;

public interface ProfileService {
    ProfileResponse getMyProfile(Jwt jwt);
    ProfileResponse updateMyProfile(Jwt jwt, UpdateProfileRequest request);
    String uploadProfilePhoto(Jwt jwt, MultipartFile file);
    byte[] getProfilePhoto(Jwt jwt);
}
