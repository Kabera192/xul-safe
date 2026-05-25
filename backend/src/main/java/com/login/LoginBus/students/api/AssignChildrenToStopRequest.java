package com.login.LoginBus.students.api;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Request to assign children to a stop.
 * Accepts both camelCase (Flutter: childIds) and snake_case (child_ids).
 * stop_type is optional — defaults to PICKUP if not provided.
 * childIds can be integers or strings (Flutter sends int IDs).
 */
public class AssignChildrenToStopRequest {

    // Accepts both 'childIds' (Flutter camelCase) and 'child_ids' (snake_case)
    // Uses List<Object> so Jackson accepts both integer and string values
    @JsonAlias("childIds")
    @JsonProperty("child_ids")
    private List<Object> childIdsRaw;

    // Flutter does not send stop_type — defaults to PICKUP
    @JsonProperty("stop_type")
    private String stopType = "PICKUP";

    public AssignChildrenToStopRequest() {}

    /** Returns child IDs as strings regardless of whether integers or strings were sent. */
    public List<String> getChildIds() {
        if (childIdsRaw == null) return List.of();
        return childIdsRaw.stream()
                .filter(v -> v != null)
                .map(Object::toString)
                .collect(Collectors.toList());
    }

    public void setChildIdsRaw(List<Object> childIdsRaw) { this.childIdsRaw = childIdsRaw; }
    public String getStopType() { return stopType; }
    public void setStopType(String stopType) { this.stopType = stopType; }
}
