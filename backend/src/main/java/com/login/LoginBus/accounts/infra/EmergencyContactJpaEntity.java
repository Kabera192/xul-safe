package com.login.LoginBus.accounts.infra;

import com.login.LoginBus.accounts.domain.EmergencyContact;
import jakarta.persistence.*;

/**
 * JPA Entity for EmergencyContact persistence.
 * Handles database mapping and conversion to/from domain entity.
 */
@Entity
@Table(name = "emergency_contacts")
public class EmergencyContactJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "phone_number", nullable = false)
    private String phoneNumber;

    @Column(nullable = false)
    private String label;

    @Column(name = "parent_id", nullable = false)
    private Long parentId;

    @Column(name = "created_at")
    private Long createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = System.currentTimeMillis();
        }
    }

    // No-arg constructor (required for JPA)
    public EmergencyContactJpaEntity() {
    }

    /**
     * Convert JPA entity to domain entity.
     *
     * @return Domain EmergencyContact entity
     */
    public EmergencyContact toDomain() {
        return new EmergencyContact(
            this.id,
            this.phoneNumber,
            this.label,
            this.parentId,
            this.createdAt
        );
    }

    /**
     * Convert domain entity to JPA entity.
     *
     * @param contact Domain EmergencyContact entity
     * @return JPA EmergencyContact entity
     */
    public static EmergencyContactJpaEntity fromDomain(EmergencyContact contact) {
        EmergencyContactJpaEntity entity = new EmergencyContactJpaEntity();
        entity.setId(contact.getId());
        entity.setPhoneNumber(contact.getPhoneNumber());
        entity.setLabel(contact.getLabel());
        entity.setParentId(contact.getParentId());
        entity.createdAt = contact.getCreatedAt();
        return entity;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public Long getParentId() {
        return parentId;
    }

    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }

    public Long getCreatedAt() {
        return createdAt;
    }
}
