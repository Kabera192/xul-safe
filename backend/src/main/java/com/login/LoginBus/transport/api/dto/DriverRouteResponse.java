package com.login.LoginBus.transport.api.dto;

/**
 * Response for the driver's route.
 * Field names match Flutter RouteModel.fromApiResponse expectations:
 *   id, name
 * Additional fields also emitted for future use.
 */
public class DriverRouteResponse {

    // Flutter reads 'id'
    private Long id;

    private String name;

    private String description;

    private String startLocation;

    private String endLocation;

    public DriverRouteResponse() {}

    public DriverRouteResponse(Long id, String name, String description,
                                String startLocation, String endLocation) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.startLocation = startLocation;
        this.endLocation = endLocation;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getStartLocation() { return startLocation; }
    public void setStartLocation(String startLocation) { this.startLocation = startLocation; }
    public String getEndLocation() { return endLocation; }
    public void setEndLocation(String endLocation) { this.endLocation = endLocation; }
}
