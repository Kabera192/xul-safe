package com.login.LoginBus.auth.app;

public interface EmailService {
    void sendOtp(String toEmail, String otp, String purpose);
}
