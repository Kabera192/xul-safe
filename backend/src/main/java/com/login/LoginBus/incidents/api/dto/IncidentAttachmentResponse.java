package com.login.LoginBus.incidents.api.dto;

import com.login.LoginBus.incidents.domain.IncidentAttachment;
import com.login.LoginBus.incidents.domain.IncidentAttachmentType;

/**
 * API-safe representation of an incident attachment.
 *
 * Internal storage information is intentionally excluded.
 */
public class IncidentAttachmentResponse {

    private Long id;
    private IncidentAttachmentType type;
    private Long createdAt;

    public IncidentAttachmentResponse() {
    }

    public IncidentAttachmentResponse(
            Long id,
            IncidentAttachmentType type,
            Long createdAt
    ) {
        this.id = id;
        this.type = type;
        this.createdAt = createdAt;
    }

    public static IncidentAttachmentResponse fromDomain(
            IncidentAttachment attachment
    ) {
        return new IncidentAttachmentResponse(
                attachment.getId(),
                attachment.getType(),
                attachment.getCreatedAt()
        );
    }

    public Long getId() {
        return id;
    }

    public IncidentAttachmentType getType() {
        return type;
    }

    public Long getCreatedAt() {
        return createdAt;
    }
}