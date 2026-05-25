package com.login.LoginBus.transport.infra;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository for Journey JPA entities.
 * This is infrastructure layer - handles database operations only.
 */
@Repository
public interface JourneyRepository extends JpaRepository<JourneyJpaEntity, Long> {

    /**
     * Find all journeys for a list of children, ordered by date and time descending.
     *
     * @param childIds List of child IDs
     * @return List of journeys
     */
    @Query("SELECT j FROM JourneyJpaEntity j WHERE j.childId IN :childIds ORDER BY j.date DESC, j.startTime DESC")
    List<JourneyJpaEntity> findByChildIdInOrderByDateDescStartTimeDesc(@Param("childIds") List<String> childIds);

    /**
     * Find all journeys for a specific route.
     *
     * @param routeId The route ID
     * @return List of journeys
     */
    List<JourneyJpaEntity> findByRouteId(Long routeId);

    /**
     * Find all journeys for a specific child.
     *
     * @param childId The child ID
     * @return List of journeys
     */
    List<JourneyJpaEntity> findByChildId(String childId);

    /**
     * Find all journeys ordered by date descending.
     *
     * @return List of all journeys
     */
    List<JourneyJpaEntity> findAllByOrderByDateDescStartTimeDesc();

    /**
     * Find journeys within a date range.
     *
     * @param startDate Start date (inclusive)
     * @param endDate End date (inclusive)
     * @return List of journeys
     */
    @Query("SELECT j FROM JourneyJpaEntity j WHERE j.date >= :startDate AND j.date <= :endDate ORDER BY j.childId, j.date, j.journeyType")
    List<JourneyJpaEntity> findByDateBetweenOrderByChildIdAndDate(
        @Param("startDate") String startDate,
        @Param("endDate") String endDate
    );
}
