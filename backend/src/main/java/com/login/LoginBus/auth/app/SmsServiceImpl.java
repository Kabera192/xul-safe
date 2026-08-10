package com.login.LoginBus.auth.app;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class SmsServiceImpl implements SmsService {

    private final String accountSid;
    private final String authToken;
    private final String fromNumber;

    public SmsServiceImpl(
            @Value("${twilio.account-sid:}") String accountSid,
            @Value("${twilio.auth-token:}") String authToken,
            @Value("${twilio.phone-number:}") String fromNumber) {
        this.accountSid = accountSid;
        this.authToken = authToken;
        this.fromNumber = fromNumber;
    }

    @Override
    public void sendOtp(String toPhoneNumber, String otp) {
        String message = "Your XUL Safe password reset code is: " + otp + ". Valid for 10 minutes. Do not share this code.";

        if (accountSid.isBlank() || authToken.isBlank() || fromNumber.isBlank()) {
            // Development fallback: print OTP to console instead of sending SMS
            System.out.println("[SMS-DEV] To: " + toPhoneNumber + " | OTP: " + otp);
            return;
        }

        Twilio.init(accountSid, authToken);
        Message.creator(
                new PhoneNumber(toPhoneNumber),
                new PhoneNumber(fromNumber),
                message
        ).create();
    }
}
