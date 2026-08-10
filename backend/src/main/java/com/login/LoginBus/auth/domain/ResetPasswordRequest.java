package com.login.LoginBus.auth.domain;

public class ResetPasswordRequest {
    private String phoneNumber;
    private String otp;
    private String newPassword;

    public ResetPasswordRequest() {}

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getOtp() { return otp; }
    public void setOtp(String otp) { this.otp = otp; }

    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
}
