package com.login.LoginBus.auth.domain;

import java.time.Instant;
import java.util.List;

/**
 * Authentication response — matches the format expected by the Flutter mobile app.
 * Fields: token, token_expires_at, refresh_token, refresh_token_expires_at, user
 */
public class AuthResponse {

    private String token;
    private Instant token_expires_at;
    private String refresh_token;
    private Instant refresh_token_expires_at;
    private UserInfo user;

    public AuthResponse() {}

    public AuthResponse(String token, Instant tokenExpiresAt,
                        String refreshToken, Instant refreshTokenExpiresAt,
                        UserInfo user) {
        this.token = token;
        this.token_expires_at = tokenExpiresAt;
        this.refresh_token = refreshToken;
        this.refresh_token_expires_at = refreshTokenExpiresAt;
        this.user = user;
    }

    public static class UserInfo {
        private Long user_id;
        private List<String> roles;

        public UserInfo() {}

        public UserInfo(Long userId, List<String> roles) {
            this.user_id = userId;
            this.roles = roles;
        }

        public Long getUser_id() { return user_id; }
        public void setUser_id(Long user_id) { this.user_id = user_id; }
        public List<String> getRoles() { return roles; }
        public void setRoles(List<String> roles) { this.roles = roles; }
    }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    public Instant getToken_expires_at() { return token_expires_at; }
    public void setToken_expires_at(Instant token_expires_at) { this.token_expires_at = token_expires_at; }
    public String getRefresh_token() { return refresh_token; }
    public void setRefresh_token(String refresh_token) { this.refresh_token = refresh_token; }
    public Instant getRefresh_token_expires_at() { return refresh_token_expires_at; }
    public void setRefresh_token_expires_at(Instant refresh_token_expires_at) { this.refresh_token_expires_at = refresh_token_expires_at; }
    public UserInfo getUser() { return user; }
    public void setUser(UserInfo user) { this.user = user; }
}

