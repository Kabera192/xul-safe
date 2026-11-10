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
