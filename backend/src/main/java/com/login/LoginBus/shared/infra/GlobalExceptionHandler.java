package com.login.LoginBus.shared.infra;

import com.login.LoginBus.common.trace.TraceIdFilter;
import com.login.LoginBus.shared.api.ErrorResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Global exception handler for all API errors.
 * Returns standardized ErrorResponse with trace_id for debugging.
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex, HttpServletRequest req) {
        Map<String, Object> details = new HashMap<>();
        Map<String, String> fieldErrors = new HashMap<>();
        for (FieldError fe : ex.getBindingResult().getFieldErrors()) {
            fieldErrors.put(fe.getField(), fe.getDefaultMessage());
        }
        details.put("fields", fieldErrors);
        details.put("path", req.getRequestURI());
        return build(req, HttpStatus.BAD_REQUEST, "VALIDATION_ERROR", "Invalid request.", details);
    }

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<ErrorResponse> handleAuth(AuthenticationException ex, HttpServletRequest req) {
        return build(req, HttpStatus.UNAUTHORIZED, "UNAUTHORIZED", "Authentication required.",
                Map.of("path", req.getRequestURI()));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ErrorResponse> handleDenied(AccessDeniedException ex, HttpServletRequest req) {
        return build(req, HttpStatus.FORBIDDEN, "FORBIDDEN", "Access denied.",
                Map.of("path", req.getRequestURI()));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArgumentException(
            IllegalArgumentException ex, HttpServletRequest req) {
        return build(req, HttpStatus.BAD_REQUEST, "INVALID_ARGUMENT", ex.getMessage(),
                Map.of("path", req.getRequestURI()));
    }

    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<ErrorResponse> handleIllegalStateException(
            IllegalStateException ex, HttpServletRequest req) {
        return build(req, HttpStatus.CONFLICT, "INVALID_STATE", ex.getMessage(),
                Map.of("path", req.getRequestURI()));
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ErrorResponse> handleRuntimeException(
            RuntimeException ex, HttpServletRequest req) {
        Map<String, Object> details = new HashMap<>();
        details.put("path", req.getRequestURI());
        details.put("exception_type", ex.getClass().getSimpleName());
        return build(req, HttpStatus.INTERNAL_SERVER_ERROR, "RUNTIME_ERROR",
                ex.getMessage() != null ? ex.getMessage() : "An unexpected error occurred", details);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(
            Exception ex, HttpServletRequest req) {
        Map<String, Object> details = new HashMap<>();
        details.put("path", req.getRequestURI());
        details.put("exception_type", ex.getClass().getSimpleName());
        return build(req, HttpStatus.INTERNAL_SERVER_ERROR, "INTERNAL_ERROR",
                ex.getMessage() != null ? ex.getMessage() : "An internal server error occurred", details);
    }

    /**
     * Custom exception for resource not found errors
     */
    public static class ResourceNotFoundException extends RuntimeException {
        public ResourceNotFoundException(String message) {
            super(message);
        }
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFoundException(
            ResourceNotFoundException ex, HttpServletRequest req) {
        return build(req, HttpStatus.NOT_FOUND, "RESOURCE_NOT_FOUND", ex.getMessage(),
                Map.of("path", req.getRequestURI()));
    }

    private ResponseEntity<ErrorResponse> build(HttpServletRequest req, HttpStatus status,
                                                  String code, String message, Map<String, Object> details) {
        String traceId = (String) req.getAttribute(TraceIdFilter.TRACE_ID_ATTR);
        if (traceId == null) traceId = UUID.randomUUID().toString();
        return ResponseEntity.status(status).body(new ErrorResponse(code, message, details, traceId));
    }
}
