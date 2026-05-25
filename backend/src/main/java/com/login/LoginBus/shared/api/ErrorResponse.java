package com.login.LoginBus.shared.api;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * Standardized error response format for all API errors.
 * Follows the architecture specification with trace_id for debugging.
 */
public class ErrorResponse {

    @JsonProperty("code")
    private String code;

    @JsonProperty("message")
    private String message;

    @JsonProperty("details")
    private Map<String, Object> details;

    @JsonProperty("trace_id")
    private String traceId;

    @JsonProperty("timestamp")
    private LocalDateTime timestamp;

    public ErrorResponse() {
    }

    public ErrorResponse(String code, String message, Map<String, Object> details, String traceId) {
        this.code = code;
        this.message = message;
        this.details = details;
        this.traceId = traceId;
        this.timestamp = LocalDateTime.now();
    }

    // Getters and setters
    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Map<String, Object> getDetails() {
        return details;
    }

    public void setDetails(Map<String, Object> details) {
        this.details = details;
    }

    public String getTraceId() {
        return traceId;
    }

    public void setTraceId(String traceId) {
        this.traceId = traceId;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
}
