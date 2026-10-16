package com.login.LoginBus.incidents.domain;

/**
 * Media attached to an incident.
 *
 * storagePath is an internal server-side path and must not be exposed
 * directly through API responses.
 */
public class IncidentAttachment {

    private Long id;
    private Long incidentId;
    private IncidentAttachmentType type;
    private String storagePath;
    private Long createdAt;

    public IncidentAttachment() {
    }

    public IncidentAttachment(
            Long id,
            Long incidentId,
            IncidentAttachmentType type,
            String storagePath,
            Long createdAt
    ) {
        this.id = id;
        this.incidentId = incidentId;
        this.type = type;
        this.storagePath = storagePath;
        this.createdAt = createdAt;
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