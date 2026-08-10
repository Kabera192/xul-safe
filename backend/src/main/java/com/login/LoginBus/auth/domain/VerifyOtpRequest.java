package com.login.LoginBus.auth.domain;

public class VerifyOtpRequest {
    private String phoneNumber;
    private String otp;

    public VerifyOtpRequest() {}

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getOtp() { return otp; }
    public void setOtp(String otp) { this.otp = otp; }
}
