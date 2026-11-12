package com.login.LoginBus;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import io.github.cdimascio.dotenv.Dotenv;

@SpringBootApplication
public class LoginBusApplication {

	public static void main(String[] args) {
		Dotenv dotenv = Dotenv.configure().load();

		System.setProperty("DB_URL", dotenv.get("DB_URL"));
        System.setProperty("DB_USER", dotenv.get("DB_USER"));
        System.setProperty("DB_PWD", dotenv.get("DB_PWD"));
		System.setProperty("JWT_SECRET", dotenv.get("JWT_SECRET"));
        System.setProperty("JWT_ISSUER", dotenv.get("JWT_ISSUER"));

        // Optional — leave unset in .env to keep using the SMS-DEV console fallback
        System.setProperty("TWILIO_ACCOUNT_SID", dotenv.get("TWILIO_ACCOUNT_SID", ""));
        System.setProperty("TWILIO_AUTH_TOKEN", dotenv.get("TWILIO_AUTH_TOKEN", ""));
        System.setProperty("TWILIO_PHONE_NUMBER", dotenv.get("TWILIO_PHONE_NUMBER", ""));
        System.setProperty("TWILIO_WHATSAPP_FROM", dotenv.get("TWILIO_WHATSAPP_FROM", ""));
        System.setProperty("TEXTBELT_KEY", dotenv.get("TEXTBELT_KEY", ""));
        System.setProperty("CALLMEBOT_APIKEY", dotenv.get("CALLMEBOT_APIKEY", ""));

        // Email OTP (password reset + account verification). Leave MAIL_USERNAME
        // unset to keep using the EMAIL-DEV console fallback.
        System.setProperty("MAIL_HOST", dotenv.get("MAIL_HOST", "smtp.gmail.com"));
        System.setProperty("MAIL_PORT", dotenv.get("MAIL_PORT", "465"));
        System.setProperty("MAIL_SSL", dotenv.get("MAIL_SSL", "true"));
        System.setProperty("MAIL_STARTTLS", dotenv.get("MAIL_STARTTLS", "false"));
        System.setProperty("MAIL_USERNAME", dotenv.get("MAIL_USERNAME", ""));
        System.setProperty("MAIL_PASSWORD", dotenv.get("MAIL_PASSWORD", ""));
        System.setProperty("MAIL_FROM", dotenv.get("MAIL_FROM", ""));

		SpringApplication.run(LoginBusApplication.class, args);
	}

}
