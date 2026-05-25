package com.login.LoginBus.accounts.infra;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ParentRepository extends JpaRepository<ParentJpaEntity, Long> {
    Optional<ParentJpaEntity> findByUserId(Long userId);
}
