package com.login.LoginBus.auth.domain;

/**
 * Login request domain object.
 * Accepts both "email" and "identifier" fields for compatibility with Flutter client.
 */
public class LoginRequest {
    private String email;
    private String identifier; // Flutter sends "identifier" instead of "email"
    private String password;

    public LoginRequest() {
    }

    public LoginRequest(String email, String password) {
        this.email = email;
        this.password = password;
    }

    /** Returns "identifier" if set (Flutter), otherwise falls back to "email". */
    public String getEmail() {
        return (identifier != null && !identifier.isBlank()) ? identifier : email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getIdentifier() {
        return identifier;
    }

    public void setIdentifier(String identifier) {
        this.identifier = identifier;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
