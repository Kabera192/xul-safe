package com.login.LoginBus.incidents.infra;

import com.login.LoginBus.incidents.domain.IncidentAttachment;
import com.login.LoginBus.incidents.domain.IncidentAttachmentType;
import jakarta.persistence.*;

/**
 * Persistence entity for incident media attachments.
 *
 * Only the storage path is persisted. The actual file remains outside
 * PostgreSQL.
 */
@Entity
@Table(name = "incident_attachments")
public class IncidentAttachmentJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "incident_id", nullable = false)
    private Long incidentId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private IncidentAttachmentType type;

    @Column(name = "storage_path", nullable = false, columnDefinition = "TEXT")
    private String storagePath;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;

    public IncidentAttachmentJpaEntity() {
    }

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = System.currentTimeMillis();
        }
    }

    public IncidentAttachment toDomain() {
        return new IncidentAttachment(
                id,
                incidentId,
                type,
                storagePath,
                createdAt
        );
    }

    public static IncidentAttachmentJpaEntity fromDomain(
            IncidentAttachment attachment
    ) {
        IncidentAttachmentJpaEntity entity =
                new IncidentAttachmentJpaEntity();

        entity.setId(attachment.getId());
        entity.setIncidentId(attachment.getIncidentId());
        entity.setType(attachment.getType());
        entity.setStoragePath(attachment.getStoragePath());
        entity.setCreatedAt(attachment.getCreatedAt());

        return entity;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getIncidentId() {
        return incidentId;
    }

    public void setIncidentId(Long incidentId) {
        this.incidentId = incidentId;
    }

    public IncidentAttachmentType getType() {
        return type;
    }

    public void setType(IncidentAttachmentType type) {
        this.type = type;
    }

    public String getStoragePath() {
        return storagePath;
    }

    public void setStoragePath(String storagePath) {
        this.storagePath = storagePath;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }
}