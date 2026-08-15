package com.login.LoginBus.students.infra;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChildRepository extends JpaRepository<ChildJpaEntity, String> {
    List<ChildJpaEntity> findByParentId(Long parentId);
    long countByParentId(Long parentId);
    List<ChildJpaEntity> findByBusId(Long busId);
    List<ChildJpaEntity> findByBusIdAndBusStopId(Long busId, String busStopId);

    @Query("SELECT c FROM ChildJpaEntity c WHERE c.busStopId = :stopId")
    List<ChildJpaEntity> findByAnyStopReference(@Param("stopId") String stopId);
}

