package com.login.LoginBus.accounts.infra;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.login.LoginBus.accounts.domain.UserRole;
import java.util.Optional;

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
}
