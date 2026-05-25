package com.login.LoginBus.config;

import com.login.LoginBus.accounts.app.AccountsPublicService;
import com.login.LoginBus.accounts.domain.User;
import com.login.LoginBus.accounts.domain.UserRole;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * Seeds a default admin user on startup if configured.
 */
@Component
public class AdminSeeder implements ApplicationRunner {

    @Value("${admin.seed.enabled:false}")
    private boolean enabled;

    @Value("${admin.seed.email:}")
    private String email;

    @Value("${admin.seed.password:}")
    private String password;

    @Value("${admin.seed.firstName:}")
    private String firstName;

    @Value("${admin.seed.lastName:}")
    private String lastName;

    @Value("${admin.seed.phoneNumber:}")
    private String phoneNumber;

    private final AccountsPublicService accountsService;
    private final PasswordEncoder passwordEncoder;

    public AdminSeeder(AccountsPublicService accountsService, PasswordEncoder passwordEncoder) {
        this.accountsService = accountsService;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(ApplicationArguments args) {
        if (!enabled || email.isBlank() || password.isBlank()) {
            return;
        }

        if (accountsService.userExists(email)) {
            return;
        }

        User admin = new User();
        admin.setFirstName(firstName.isBlank() ? "Admin" : firstName);
        admin.setLastName(lastName.isBlank() ? "User" : lastName);
        admin.setEmail(email);
        admin.setPassword(passwordEncoder.encode(password));
        admin.setPhoneNumber(phoneNumber.isBlank() ? "0000000000" : phoneNumber);
        admin.setRole(UserRole.ADMIN);

        accountsService.createUser(admin);
    }
}
