package com.login.LoginBus.config;

import com.login.LoginBus.accounts.infra.UserJpaEntity;
import com.login.LoginBus.accounts.infra.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * One-time cleanup for accounts created before every write path normalized
 * email casing (see AccountsServiceImpl.createUser / AuthServiceImpl).
 * Idempotent and cheap once there's nothing left to fix, so it's safe to
 * run on every startup rather than as a manual, one-off migration.
 *
 * Normalizes one row at a time instead of a single bulk UPDATE: if two
 * mixed-case rows would collide once lowercased (e.g. "Foo@Bar.com" and
 * "foo@bar.com" both exist), that pair is a pre-existing data problem this
 * runner can't safely resolve on its own — it logs a warning and leaves
 * both rows untouched rather than guessing which one to keep.
 */
@Component
public class EmailNormalizationRunner implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(EmailNormalizationRunner.class);

    private final UserRepository userRepository;

    public EmailNormalizationRunner(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public void run(ApplicationArguments args) {
        List<UserJpaEntity> mixedCase = userRepository.findWithMixedCaseEmail();
        if (mixedCase.isEmpty()) return;

        for (UserJpaEntity user : mixedCase) {
            String normalized = user.getEmail().trim().toLowerCase();
            try {
                user.setEmail(normalized);
                userRepository.save(user);
                log.info("Normalized email casing for user id={}", user.getId());
            } catch (Exception e) {
                log.warn("Could not normalize email for user id={} (likely collides with an "
                        + "existing account once lowercased) — left as-is for manual review.",
                        user.getId());
            }
        }
    }
}
