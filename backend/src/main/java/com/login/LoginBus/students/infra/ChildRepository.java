package com.login.LoginBus.students.infra;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChildRepository extends JpaRepository<ChildJpaEntity, String> {
    List<ChildJpaEntity> findByParentId(Long parentId);
    long countByParentId(Long parentId);
    List<ChildJpaEntity> findByBusId(Long busId);
    List<ChildJpaEntity> findByBusIdAndPickupStopId(Long busId, Long pickupStopId);
    List<ChildJpaEntity> findByBusIdAndDropoffStopId(Long busId, Long dropoffStopId);
}

