package com.login.LoginBus.auth.app;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailServiceImpl implements EmailService {

    private final JavaMailSender mailSender;
    private final String fromAddress;
    private final boolean mailConfigured;

    public EmailServiceImpl(
            JavaMailSender mailSender,
            @Value("${spring.mail.username:}") String mailUsername,
            @Value("${mail.from:}") String mailFrom) {
        this.mailSender = mailSender;
        this.fromAddress = !mailFrom.isBlank() ? mailFrom : mailUsername;
        this.mailConfigured = !mailUsername.isBlank();
    }

    @Override
    public void sendOtp(String toEmail, String otp, String purpose) {
        String subject = "XUL Safe - " + purpose + " code";
        String body = "Your XUL Safe " + purpose.toLowerCase() + " code is: " + otp
                + "\n\nValid for 10 minutes. Do not share this code with anyone.";

        // No SMTP configured (e.g. local dev) — print instead of sending.
        if (!mailConfigured) {
            System.out.println("[EMAIL-DEV] To: " + toEmail + " | Subject: " + subject + " | OTP: " + otp);
            return;
        }

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromAddress);
            message.setTo(toEmail);
            message.setSubject(subject);
            message.setText(body);
            mailSender.send(message);
        } catch (Exception e) {
            System.err.println("[EMAIL] Send failed, falling back to console: " + e.getMessage());
            System.out.println("[EMAIL-DEV] To: " + toEmail + " | Subject: " + subject + " | OTP: " + otp);
        }
    }
}
