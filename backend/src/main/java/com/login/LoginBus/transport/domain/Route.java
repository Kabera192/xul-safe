package com.login.LoginBus.transport.domain;

/**
 * Pure domain entity for Route.
 * A route represents a path that buses travel, containing multiple bus stops.
 */
public class Route {

    private Long id;
    private String name;
    private String description;
    private String startLocation;
    private String endLocation;
    private Long createdAt;

    // No-arg constructor
    public Route() {
    }

    // Full constructor
    public Route(Long id, String name, String description, String startLocation,
                 String endLocation, Long createdAt) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.startLocation = startLocation;
        this.endLocation = endLocation;
        this.createdAt = createdAt;
    }

    // Business logic methods
    public String getDisplayName() {
        if (startLocation != null && endLocation != null) {
            return startLocation + " - " + endLocation;
        }
        return name;
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

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }
}
