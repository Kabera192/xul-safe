package com.login.LoginBus.students.api;

import com.login.LoginBus.shared.api.ApiResponse;
import com.login.LoginBus.students.app.StudentsService;
import com.login.LoginBus.students.domain.Absence;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST controller for absence operations.
 * All endpoints use /api/v1 prefix for versioning.
 */
@RestController
@RequestMapping("/api/v1/absences")
@CrossOrigin(origins = "*")
public class AbsenceController {

    @Autowired
    private StudentsService studentsService;

    /**
     * Get all absences across all students (admin).
     * GET /api/v1/absences/all
     *
     * @return List of all absences enriched with child name
     */
    @GetMapping("/all")
    public ResponseEntity<ApiResponse<List<Absence>>> getAllAbsences() {
        List<Absence> absences = studentsService.getAllAbsences();
        return ResponseEntity.ok(new ApiResponse<>(
            "All absences retrieved successfully",
            absences
        ));
    }

    /**
     * Get all absences for a child.
     * GET /api/v1/absences?child_id={childId}
     *
     * @param childId The child ID
     * @return List of absences
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<Absence>>> getAbsences(@RequestParam("child_id") String childId) {
        List<Absence> absences = studentsService.getAbsencesForChild(childId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Absences retrieved successfully",
            absences
        ));
    }

    /**
     * Get all absences for a parent.
     * GET /api/v1/absences/parent/{parentId}
     *
     * @param parentId The parent ID
     * @return List of absences
     */
    @GetMapping("/parent/{parentId}")
    public ResponseEntity<ApiResponse<List<Absence>>> getAbsencesForParent(@PathVariable Long parentId) {
        List<Absence> absences = studentsService.getAbsencesForParent(parentId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Absences retrieved successfully",
            absences
        ));
    }

    /**
     * Get active absences for a parent.
     * GET /api/v1/absences/parent/{parentId}/active
     *
     * @param parentId The parent ID
     * @return List of active absences
     */
    @GetMapping("/parent/{parentId}/active")
    public ResponseEntity<ApiResponse<List<Absence>>> getActiveAbsencesForParent(@PathVariable Long parentId) {
        List<Absence> absences = studentsService.getActiveAbsencesForParent(parentId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Active absences retrieved successfully",
            absences
        ));
    }

    /**
     * Create a new absence.
     * POST /api/v1/absences
     *
     * Request body:
     * {
     *   "childId": "child123",
     *   "parentId": 1,
     *   "absenceType": "MORNING",
     *   "startDate": "2024-01-20",
     *   "endDate": "2024-01-20",
     *   "status": "ACTIVE"
     * }
     *
     * @param absence The absence to create
     * @return The created absence
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Absence>> createAbsence(@RequestBody Absence absence) {
        if (absence.getChildId() == null || absence.getChildId().trim().isEmpty()) {
            throw new IllegalArgumentException("Child ID is required");
        }
        if (absence.getParentId() == null) {
            throw new IllegalArgumentException("Parent ID is required");
        }
        if (absence.getAbsenceType() == null) {
            throw new IllegalArgumentException("Absence type is required");
        }
        if (absence.getStartDate() == null || absence.getEndDate() == null) {
            throw new IllegalArgumentException("Start date and end date are required");
        }

        Absence created = studentsService.createAbsence(absence);

        return ResponseEntity.status(HttpStatus.CREATED).body(new ApiResponse<>(
            "Absence created successfully",
            created
        ));
    }

    /**
     * Update an existing absence.
     * PUT /api/v1/absences/{absenceId}
     *
     * @param absenceId The absence ID
     * @param absence The updated absence data
     * @return The updated absence
     */
    @PutMapping("/{absenceId}")
    public ResponseEntity<ApiResponse<Absence>> updateAbsence(
            @PathVariable Long absenceId,
            @RequestBody Absence absence) {

        Absence updated = studentsService.updateAbsence(absenceId, absence);

        return ResponseEntity.ok(new ApiResponse<>(
            "Absence updated successfully",
            updated
        ));
    }

    /**
     * Delete an absence.
     * DELETE /api/v1/absences/{absenceId}
     *
     * @param absenceId The absence ID
     * @return Success message
     */
    @DeleteMapping("/{absenceId}")
    public ResponseEntity<ApiResponse<Void>> deleteAbsence(@PathVariable Long absenceId) {
        studentsService.deleteAbsence(absenceId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Absence deleted successfully",
            null
        ));
    }

    /**
     * Complete an absence (mark as completed early).
     * POST /api/v1/absences/{absenceId}/complete
     *
     * @param absenceId The absence ID
     * @return Success message
     */
    @PostMapping("/{absenceId}/complete")
    public ResponseEntity<ApiResponse<Absence>> completeAbsence(@PathVariable Long absenceId) {
        Absence completed = studentsService.completeAbsence(absenceId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Absence completed successfully",
            completed
        ));
    }
}
