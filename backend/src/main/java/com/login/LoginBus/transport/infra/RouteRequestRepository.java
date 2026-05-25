package com.login.LoginBus.transport.infra;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RouteRequestRepository extends JpaRepository<RouteRequestJpaEntity, Long> {
}
