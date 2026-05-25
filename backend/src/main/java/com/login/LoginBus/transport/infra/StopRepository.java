package com.login.LoginBus.transport.infra;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface StopRepository extends JpaRepository<StopJpaEntity, Long> {
    List<StopJpaEntity> findByRouteIdOrderByOrderIndexAsc(Long routeId);
}
