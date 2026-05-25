package com.login.LoginBus.accounts.api;

import com.login.LoginBus.accounts.app.AccountsService;
import com.login.LoginBus.accounts.domain.EmergencyContact;
import com.login.LoginBus.shared.api.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for emergency contact operations.
 * All endpoints use /api/v1 prefix for versioning.
 */
@RestController
@RequestMapping("/api/v1/emergency-contacts")
@CrossOrigin(origins = "*")
public class EmergencyContactController {

    @Autowired
    private AccountsService accountsService;

    /**
     * Get all emergency contacts for a parent.
     * GET /api/v1/emergency-contacts/{parentId}
     *
     * @param parentId The parent ID
     * @return List of emergency contacts
     */
    @GetMapping("/{parentId}")
    public ResponseEntity<ApiResponse<List<EmergencyContact>>> getContacts(@PathVariable Long parentId) {
        List<EmergencyContact> contacts = accountsService.getEmergencyContactsByParent(parentId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Emergency contacts retrieved successfully",
            contacts
        ));
    }

    /**
     * Create a new emergency contact.
     * POST /api/v1/emergency-contacts
     *
     * Request body:
     * {
     *   "phoneNumber": "+1234567890",
     *   "label": "Aunt",
     *   "parentId": 1
     * }
     *
     * @param contact The contact to create
     * @return The created contact
     */
    @PostMapping
    public ResponseEntity<ApiResponse<EmergencyContact>> createContact(@RequestBody EmergencyContact contact) {
        if (contact.getPhoneNumber() == null || contact.getPhoneNumber().trim().isEmpty()) {
            throw new IllegalArgumentException("Phone number is required");
        }
        if (contact.getLabel() == null || contact.getLabel().trim().isEmpty()) {
            throw new IllegalArgumentException("Label is required");
        }
        if (contact.getParentId() == null) {
            throw new IllegalArgumentException("Parent ID is required");
        }

        EmergencyContact created = accountsService.createEmergencyContact(contact);

        return ResponseEntity.status(HttpStatus.CREATED).body(new ApiResponse<>(
            "Emergency contact created successfully",
            created
        ));
    }

    /**
     * Update an existing emergency contact.
     * PUT /api/v1/emergency-contacts/{contactId}
     *
     * @param contactId The contact ID
     * @param contact The updated contact data
     * @return The updated contact
     */
    @PutMapping("/{contactId}")
    public ResponseEntity<ApiResponse<EmergencyContact>> updateContact(
            @PathVariable Long contactId,
            @RequestBody EmergencyContact contact) {

        EmergencyContact updated = accountsService.updateEmergencyContact(contactId, contact);

        return ResponseEntity.ok(new ApiResponse<>(
            "Emergency contact updated successfully",
            updated
        ));
    }

    /**
     * Delete an emergency contact.
     * DELETE /api/v1/emergency-contacts/{parentId}/{contactId}
     *
     * @param parentId The parent ID
     * @param contactId The contact ID
     * @return Success message
     */
    @DeleteMapping("/{parentId}/{contactId}")
    public ResponseEntity<ApiResponse<Void>> deleteContact(
            @PathVariable Long parentId,
            @PathVariable Long contactId) {

        accountsService.deleteEmergencyContact(parentId, contactId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Emergency contact deleted successfully",
            null
        ));
    }
}
