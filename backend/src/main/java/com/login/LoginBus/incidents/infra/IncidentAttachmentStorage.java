package com.login.LoginBus.incidents.infra;

import com.login.LoginBus.incidents.domain.IncidentAttachmentType;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

/**
 * Stores and retrieves incident attachment files.
 *
 * Incident media is intentionally stored outside the public /uploads
 * directory so files cannot be accessed through the application's
 * static resource handler.
 */
@Component
public class IncidentAttachmentStorage {

    private static final Path STORAGE_DIR =
            Paths.get("incident-storage").toAbsolutePath().normalize();

    private static final long MAX_IMAGE_SIZE =
            10L * 1024 * 1024; // 10 MB

    private static final long MAX_AUDIO_SIZE =
            10L * 1024 * 1024; // 10 MB

    /**
     * Validate and store an incident attachment.
     *
     * The returned path is internal server-side information and must not
     * be exposed directly through API responses.
     */
    public String store(
            MultipartFile file,
            IncidentAttachmentType type
    ) {
        validate(file, type);

        try {
            Files.createDirectories(STORAGE_DIR);

            String extension = extensionFor(
                    file.getContentType(),
                    type
            );

            String filename =
                    UUID.randomUUID() + extension;

            Path destination =
                    STORAGE_DIR.resolve(filename).normalize();

            if (!destination.startsWith(STORAGE_DIR)) {
                throw new IllegalArgumentException(
                        "Invalid attachment storage path"
                );
            }

            Files.copy(
                    file.getInputStream(),
                    destination,
                    StandardCopyOption.REPLACE_EXISTING
            );

            return destination.toString();

        } catch (IOException e) {
            throw new IllegalStateException(
                    "Failed to store incident attachment",
                    e
            );
        }
    }

    /**
     * Read a previously stored attachment.
     */
    public byte[] read(String storagePath) {
        if (storagePath == null || storagePath.isBlank()) {
            throw new IllegalArgumentException(
                    "Attachment storage path is required"
            );
        }

        Path path =
                Paths.get(storagePath)
                        .toAbsolutePath()
                        .normalize();

        if (!path.startsWith(STORAGE_DIR)) {
            throw new IllegalArgumentException(
                    "Invalid attachment storage path"
            );
        }

        try {
            return Files.readAllBytes(path);
        } catch (IOException e) {
            throw new IllegalStateException(
                    "Failed to read incident attachment",
                    e
            );
        }
    }

    /**
     * Delete a stored attachment file.
     *
     * This will be useful for failed persistence and future attachment
     * replacement/deletion.
     */
    public void delete(String storagePath) {
        if (storagePath == null || storagePath.isBlank()) {
            return;
        }

        Path path =
                Paths.get(storagePath)
                        .toAbsolutePath()
                        .normalize();

        if (!path.startsWith(STORAGE_DIR)) {
            throw new IllegalArgumentException(
                    "Invalid attachment storage path"
            );
        }

        try {
            Files.deleteIfExists(path);
        } catch (IOException e) {
            throw new IllegalStateException(
                    "Failed to delete incident attachment",
                    e
            );
        }
    }

    private void validate(
            MultipartFile file,
            IncidentAttachmentType type
    ) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException(
                    "Attachment file is required"
            );
        }

        if (type == null) {
            throw new IllegalArgumentException(
                    "Attachment type is required"
            );
        }

        long maxSize = switch (type) {
            case IMAGE -> MAX_IMAGE_SIZE;
            case AUDIO -> MAX_AUDIO_SIZE;
        };

        if (file.getSize() > maxSize) {
            throw new IllegalArgumentException(
                    type == IncidentAttachmentType.IMAGE
                            ? "Image size exceeds 10MB"
                            : "Voice note size exceeds 10MB"
            );
        }

        // Also verifies that the supplied content type is one we support.
        extensionFor(file.getContentType(), type);
    }

    private String extensionFor(
            String contentType,
            IncidentAttachmentType type
    ) {
        if (contentType == null || contentType.isBlank()) {
            throw new IllegalArgumentException(
                    "Attachment content type is required"
            );
        }

        String normalized =
                contentType.trim().toLowerCase();

        return switch (type) {
            case IMAGE -> switch (normalized) {
                case "image/jpeg" -> ".jpg";
                case "image/png" -> ".png";
                case "image/webp" -> ".webp";
                default -> throw new IllegalArgumentException(
                        "Unsupported image type: " + contentType
                );
            };

            case AUDIO -> switch (normalized) {
                /*
                 * V1 audio is a voice note recorded by BussApp rather
                 * than an arbitrary audio file selected by the user.
                 *
                 * audio/mp4 is the normal MIME type for AAC audio in
                 * an M4A/MP4 container.
                 */
                case "audio/mp4" -> ".m4a";
                default -> throw new IllegalArgumentException(
                        "Unsupported voice note type: " + contentType
                );
            };
        };
    }
}