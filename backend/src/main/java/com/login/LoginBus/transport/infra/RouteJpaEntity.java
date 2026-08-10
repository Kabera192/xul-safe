package com.login.LoginBus.transport.infra;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.login.LoginBus.transport.domain.Route;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.time.ZoneOffset;

/**
 * JPA Entity for Route persistence.
 * Handles database mapping and conversion to/from domain entity.
 */
@Entity
@Table(name = "routes")
public class RouteJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column
    private String description;

    @Column(name = "start_location")
    @JsonProperty("startLocation")
    private String startLocation;

    @Column(name = "end_location")
    @JsonProperty("endLocation")
    private String endLocation;

    @Column(name = "created_at")
    @JsonProperty("createdAt")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    // No-arg constructor (required for JPA)
    public RouteJpaEntity() {
    }

    /**
     * Convert JPA entity to domain entity.
     *
     * @return Domain Route entity
     */
    public Route toDomain() {
        Long createdAtMillis = (this.createdAt != null)
                ? this.createdAt.toInstant(ZoneOffset.UTC).toEpochMilli()
                : null;
        return new Route(
            this.id,
            this.name,
            this.description,
            this.startLocation,
            this.endLocation,
            createdAtMillis
        );
    }

    /**
     * Convert domain entity to JPA entity.
     *
     * @param route Domain Route entity
     * @return JPA Route entity
     */
    public static RouteJpaEntity fromDomain(Route route) {
        RouteJpaEntity entity = new RouteJpaEntity();
        entity.setId(route.getId());
        entity.setName(route.getName());
        entity.setDescription(route.getDescription());
        entity.setStartLocation(route.getStartLocation());
        entity.setEndLocation(route.getEndLocation());
        if (route.getCreatedAt() != null) {
            entity.createdAt = LocalDateTime.ofEpochSecond(
                    route.getCreatedAt() / 1000,
                    (int) ((route.getCreatedAt() % 1000) * 1_000_000),
                    ZoneOffset.UTC);
        }
        return entity;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStartLocation() {
        return startLocation;
    }

    public void setStartLocation(String startLocation) {
        this.startLocation = startLocation;
    }

    public String getEndLocation() {
        return endLocation;
    }

    public void setEndLocation(String endLocation) {
        this.endLocation = endLocation;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}
