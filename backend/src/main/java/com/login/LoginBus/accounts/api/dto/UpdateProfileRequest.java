package com.login.LoginBus.accounts.api.dto;

import com.fasterxml.jackson.annotation.JsonAlias;

/**
 * Request to update profile fields.
 * Accepts both camelCase (Flutter: firstName, lastName, phoneNumber)
 * and snake_case (first_name, last_name, phone_number).
 */
public class UpdateProfileRequest {

    @JsonAlias("first_name")
    private String firstName;

    @JsonAlias("last_name")
    private String lastName;

    @JsonAlias("phone_number")
    private String phoneNumber;

    private String email;

    public UpdateProfileRequest() {}

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
