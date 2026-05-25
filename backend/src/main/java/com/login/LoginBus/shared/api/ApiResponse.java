package com.login.LoginBus.shared.api;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Standardized successful API response format.
 * Wraps all successful responses with a message and data payload.
 *
 * @param <T> The type of data being returned
 */
public class ApiResponse<T> {

    @JsonProperty("message")
    private String message;

    @JsonProperty("data")
    private T data;

    public ApiResponse() {
    }

    public ApiResponse(String message, T data) {
        this.message = message;
        this.data = data;
    }

    // Getters and setters
    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }
}
