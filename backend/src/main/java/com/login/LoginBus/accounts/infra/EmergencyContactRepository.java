package com.login.LoginBus.accounts.infra;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository for EmergencyContact JPA entities.
 * This is infrastructure layer - handles database operations only.
 */
@Repository
public interface EmergencyContactRepository extends JpaRepository<EmergencyContactJpaEntity, Long> {

    /**
     * Find all emergency contacts for a specific parent.
     *
     * @param parentId The parent ID
     * @return List of emergency contacts
     */
    List<EmergencyContactJpaEntity> findByParentId(Long parentId);

    /**
     * Delete emergency contact by parent ID and contact ID.
     *
     * @param parentId The parent ID
     * @param id The contact ID
     */
    void deleteByParentIdAndId(Long parentId, Long id);

    /**
     * Count emergency contacts for a specific parent.
     *
     * @param parentId The parent ID
     * @return Number of contacts
     */
    long countByParentId(Long parentId);
}
