package com.login.LoginBus.incidents.infra;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface IncidentAttachmentRepository
        extends JpaRepository<IncidentAttachmentJpaEntity, Long> {

    List<IncidentAttachmentJpaEntity>
            findAllByIncidentIdOrderByCreatedAtAsc(Long incidentId);

    Optional<IncidentAttachmentJpaEntity>
            findByIdAndIncidentId(Long id, Long incidentId);
}