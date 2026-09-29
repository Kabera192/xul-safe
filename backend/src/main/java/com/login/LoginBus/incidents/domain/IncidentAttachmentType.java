package com.login.LoginBus.incidents.domain;

/**
 * Types of media that may be attached to an incident.
 *
 * The backend supports multiple attachments per incident even though
 * the current mobile UI exposes only one image and one voice note.
 */
public enum IncidentAttachmentType {
    IMAGE,
    AUDIO
}