package com.login.LoginBus.auth.app;

public interface SmsService {
    void sendOtp(String toPhoneNumber, String otp);
}
