package com.login.LoginBus.accounts.infra;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface DriverRepository extends JpaRepository<DriverJpaEntity, Long> {
    Optional<DriverJpaEntity> findByUserId(Long userId);
}
