package com.login.LoginBus.shared.infra;

import java.util.regex.Pattern;

/**
 * Strips raw database IDs from exception messages before they reach the
 * client. Service code throws messages like "Conductor not found with ID: 5"
 * for logging purposes; exposing that raw numeric/UUID value to the admin UI
 * is neither user-friendly (the admin never sees or picks an ID) nor safe
 * (it leaks internal record identifiers/existence to the client).
 */
public final class ErrorSanitizer {

    private static final Pattern TRAILING_ID = Pattern.compile("(?i)\\s+with\\s+id:?\\s*\\S+\\s*$");

    private ErrorSanitizer() {
    }

    public static String sanitize(String message) {
        if (message == null) {
            return null;
        }
        String cleaned = TRAILING_ID.matcher(message).replaceAll("").trim();
        if (cleaned.isEmpty()) {
            return message;
        }
        if (!cleaned.endsWith(".") && !cleaned.endsWith("!") && !cleaned.endsWith("?")) {
            cleaned = cleaned + ".";
        }
        return cleaned;
    }
}
