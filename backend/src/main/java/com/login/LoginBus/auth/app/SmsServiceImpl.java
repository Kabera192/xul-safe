package com.login.LoginBus.auth.app;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

@Service
public class SmsServiceImpl implements SmsService {

    private final String accountSid;
    private final String authToken;
    private final String fromNumber;
    private final String whatsappFrom;
    private final String textbeltKey;
    private final String callMeBotApiKey;

    private final HttpClient httpClient = HttpClient.newHttpClient();

    public SmsServiceImpl(
            @Value("${twilio.account-sid:}") String accountSid,
            @Value("${twilio.auth-token:}") String authToken,
            @Value("${twilio.phone-number:}") String fromNumber,
            @Value("${twilio.whatsapp-from:}") String whatsappFrom,
            @Value("${textbelt.key:}") String textbeltKey,
            @Value("${callmebot.apikey:}") String callMeBotApiKey) {
        this.accountSid = accountSid;
        this.authToken = authToken;
        this.fromNumber = fromNumber;
        this.whatsappFrom = whatsappFrom;
        this.textbeltKey = textbeltKey;
        this.callMeBotApiKey = callMeBotApiKey;
    }

    @Override
    public void sendOtp(String toPhoneNumber, String otp) {
        String message = "Your XUL Safe password reset code is: " + otp + ". Valid for 10 minutes. Do not share this code.";

        // CallMeBot first — a free WhatsApp relay with zero account/business setup.
        // It only delivers to the single number that generated the API key, so
        // it's strictly a testing tool, never a path for real users.
        if (!callMeBotApiKey.isBlank()) {
            sendViaCallMeBot(toPhoneNumber, otp, message);
            return;
        }

        // Twilio WhatsApp sandbox — no per-country SMS block and no "verified
        // caller ID" step (joining the sandbox from the phone itself is the
        // verification), so it's the next-least-friction option.
        if (!accountSid.isBlank() && !authToken.isBlank() && !whatsappFrom.isBlank()) {
            Twilio.init(accountSid, authToken);
            Message.creator(
                    new PhoneNumber("whatsapp:" + toPhoneNumber),
                    new PhoneNumber(whatsappFrom.startsWith("whatsapp:") ? whatsappFrom : "whatsapp:" + whatsappFrom),
                    message
            ).create();
            return;
        }

        if (!accountSid.isBlank() && !authToken.isBlank() && !fromNumber.isBlank()) {
            Twilio.init(accountSid, authToken);
            Message.creator(
                    new PhoneNumber(toPhoneNumber),
                    new PhoneNumber(fromNumber),
                    message
            ).create();
            return;
        }

        if (!textbeltKey.isBlank()) {
            sendViaTextbelt(toPhoneNumber, otp, message);
            return;
        }

        // Development fallback: print OTP to console instead of sending SMS
        System.out.println("[SMS-DEV] To: " + toPhoneNumber + " | OTP: " + otp);
    }

    // CallMeBot (callmebot.com) — free personal WhatsApp relay. The apikey is
    // bound to one WhatsApp number (the one that requested it), so toPhoneNumber
    // must match that number or CallMeBot will reject the send.
    private void sendViaCallMeBot(String toPhoneNumber, String otp, String message) {
        try {
            String url = "https://api.callmebot.com/whatsapp.php"
                    + "?phone=" + URLEncoder.encode(toPhoneNumber, StandardCharsets.UTF_8)
                    + "&text=" + URLEncoder.encode(message, StandardCharsets.UTF_8)
                    + "&apikey=" + URLEncoder.encode(callMeBotApiKey, StandardCharsets.UTF_8);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .GET()
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            System.out.println("[WHATSAPP-CALLMEBOT] To: " + toPhoneNumber + " | response: " + response.body());
        } catch (Exception e) {
            System.err.println("[WHATSAPP-CALLMEBOT] Send failed, falling back to console: " + e.getMessage());
            System.out.println("[SMS-DEV] To: " + toPhoneNumber + " | OTP: " + otp);
        }
    }

    // Textbelt (textbelt.com) — zero-signup SMS gateway, handy for testing without
    // Twilio's trial-account "verified destination number" restriction. The shared
    // free key ("textbelt") allows one text per day per IP; a paid key lifts that.
    private void sendViaTextbelt(String toPhoneNumber, String otp, String message) {
        try {
            String body = "phone=" + URLEncoder.encode(toPhoneNumber, StandardCharsets.UTF_8)
                    + "&message=" + URLEncoder.encode(message, StandardCharsets.UTF_8)
                    + "&key=" + URLEncoder.encode(textbeltKey, StandardCharsets.UTF_8);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://textbelt.com/text"))
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            System.out.println("[SMS-TEXTBELT] To: " + toPhoneNumber + " | response: " + response.body());
        } catch (Exception e) {
            System.err.println("[SMS-TEXTBELT] Send failed, falling back to console: " + e.getMessage());
            System.out.println("[SMS-DEV] To: " + toPhoneNumber + " | OTP: " + otp);
        }
    }
}
