package com.login.LoginBus.common.error;

import com.login.LoginBus.common.trace.TraceIdFilter;
import com.login.LoginBus.shared.api.ErrorResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.NoHandlerFoundException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import java.util.Map;
import java.util.UUID;

/**
 * Handles unmatched routes (404/405) as structured JSON.
 * Complements GlobalExceptionHandler for Spring MVC routing exceptions.
 */
@RestControllerAdvice
public class NotFoundHandler {

    @ExceptionHandler(NoResourceFoundException.class)
    public ResponseEntity<ErrorResponse> handleNoResource(NoResourceFoundException ex, HttpServletRequest req) {
        return build(req, HttpStatus.NOT_FOUND, "NOT_FOUND", "Resource not found.");
    }

    @ExceptionHandler(NoHandlerFoundException.class)
    public ResponseEntity<ErrorResponse> handleNoHandler(NoHandlerFoundException ex, HttpServletRequest req) {
        return build(req, HttpStatus.NOT_FOUND, "NOT_FOUND", "Resource not found.");
    }

    private ResponseEntity<ErrorResponse> build(HttpServletRequest req, HttpStatus status, String code, String message) {
        String traceId = (String) req.getAttribute(TraceIdFilter.TRACE_ID_ATTR);
        if (traceId == null) traceId = UUID.randomUUID().toString();
        ErrorResponse body = new ErrorResponse(code, message, Map.of("path", req.getRequestURI()), traceId);
        return ResponseEntity.status(status).body(body);
    }
}
