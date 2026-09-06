package com.login.LoginBus.incidents.api;

import com.login.LoginBus.shared.api.ApiResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * Handles exceptions raised by the incidents module and converts them
 * into client-friendly HTTP responses.
 */
@RestControllerAdvice(assignableTypes = IncidentController.class)
public class IncidentExceptionHandler {

    /**
     * Invalid incident input, nonexistent referenced resources,
     * invalid lifecycle operations, or unauthorized incident targets.
     */
    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiResponse<Void>> handleIllegalArgument(
            IllegalArgumentException exception
    ) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ApiResponse<>(
                        exception.getMessage(),
                        null
                ));
    }

    /**
     * Required project services being unavailable is a server-side problem.
     */
    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<ApiResponse<Void>> handleIllegalState(
            IllegalStateException exception
    ) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ApiResponse<>(
                        exception.getMessage(),
                        null
                ));
    }
}