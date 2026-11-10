package com.login.LoginBus.auth.domain;

public class VerifyOtpRequest {
    private String email;
    private String otp;
    // Only used by /verify-registration — the password the user wants
    // active on this account. Ignored by /verify-otp (forgot-password's
    // pre-check), which doesn't set any credential.
    private String password;

    public VerifyOtpRequest() {}

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getOtp() { return otp; }
    public void setOtp(String otp) { this.otp = otp; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
