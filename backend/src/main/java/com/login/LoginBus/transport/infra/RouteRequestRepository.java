package com.login.LoginBus.transport.infra;

import com.login.LoginBus.transport.domain.RouteRequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RouteRequestRepository extends JpaRepository<RouteRequestJpaEntity, Long> {
    List<RouteRequestJpaEntity> findByChildIdAndStatus(String childId, RouteRequestStatus status);
}
