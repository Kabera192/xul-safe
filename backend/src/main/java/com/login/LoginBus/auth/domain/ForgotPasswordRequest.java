package com.login.LoginBus.auth.domain;

public class ForgotPasswordRequest {
    private String phoneNumber;

    public ForgotPasswordRequest() {}

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
}
