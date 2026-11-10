package com.login.LoginBus.accounts.infra;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.login.LoginBus.accounts.domain.UserRole;
import java.util.Optional;
import java.util.List;

/**
 * Repository for User JPA entities.
 * This is infrastructure layer - handles database operations only.
 */
@Repository
public interface UserRepository extends JpaRepository<UserJpaEntity, Long> {

    /**
     * Find a user by email.
     *
     * @param email The email address
     * @return Optional containing user if found
     */
    Optional<UserJpaEntity> findByEmail(String email);

    /**
     * Check if a user exists with the given email.
     *
     * @param email The email address
     * @return true if user exists, false otherwise
     */
    boolean existsByEmail(String email);

    /**
     * Check if any user exists with the given role.
     *
     * @param role The user role
     * @return true if at least one user with that role exists
     */
    boolean existsByRole(UserRole role);

    List<UserJpaEntity> findByRole(UserRole role);

    /**
     * Atomically consumes one OTP attempt, only if the user is still under
     * the attempt limit. The WHERE clause and the increment happen in the
     * same database statement, so concurrent calls can't all read the same
     * starting count and all "succeed" — the DB serializes the UPDATE.
     *
     * @return number of rows updated: 1 if the attempt was consumed, 0 if
     *         the limit was already reached
     */
    @Modifying
    @Query("UPDATE UserJpaEntity u SET u.otpAttempts = u.otpAttempts + 1 WHERE u.id = :id AND u.otpAttempts < :maxAttempts")
    int incrementOtpAttemptsIfBelowLimit(@Param("id") Long id, @Param("maxAttempts") int maxAttempts);
}
