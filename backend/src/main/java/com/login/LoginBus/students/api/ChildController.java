package com.login.LoginBus.students.api;

import com.login.LoginBus.accounts.app.AccountsService;
import com.login.LoginBus.accounts.domain.Conductor;
import com.login.LoginBus.shared.api.ApiResponse;
import com.login.LoginBus.students.app.StudentsService;
import com.login.LoginBus.students.domain.Absence;
import com.login.LoginBus.students.domain.Child;
import com.login.LoginBus.students.infra.ChildJpaEntity;
import com.login.LoginBus.transport.app.TransportService;
import com.login.LoginBus.transport.domain.Bus;
import com.login.LoginBus.transport.domain.BusStop;
import com.login.LoginBus.transport.domain.Route;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * REST controller for child operations.
 * All endpoints use /api/v1 prefix for versioning.
 */
@RestController
@RequestMapping("/api/v1/children")
@CrossOrigin(origins = "*")
public class ChildController {

    @Autowired
    private StudentsService studentsService;

    @Autowired
    private TransportService transportService;

    @Autowired
    private AccountsService accountsService;

    /**
     * Get all children for a parent (query param version).
     * GET /api/v1/children?parent_id={parentId}
     *
     * @param parentId The parent ID
     * @return List of children
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<Child>>> getChildren(@RequestParam("parent_id") Long parentId) {
        List<Child> children = studentsService.getChildrenForParent(parentId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Children retrieved successfully",
            children
        ));
    }

    /**
     * Get all children (admin).
     * GET /api/v1/children/all
     *
     * @return List of children
     */
    @GetMapping("/all")
    public ResponseEntity<ApiResponse<List<Child>>> getAllChildren() {
        List<Child> children = studentsService.getAllChildren();

        return ResponseEntity.ok(new ApiResponse<>(
            "All children retrieved successfully",
            children
        ));
    }

    /**
     * Get all children with enriched data (admin).
     * GET /api/v1/children/admin/details
     *
     * Returns children with bus, route, and bus stop names.
     *
     * @return List of enriched children
     */
    @GetMapping("/admin/details")
    public ResponseEntity<ApiResponse<List<ChildDetailDto>>> getAllChildrenWithDetails() {
        List<Child> children = studentsService.getAllChildren();
        List<ChildDetailDto> enrichedChildren = new ArrayList<>();

        for (Child child : children) {
            String busPlateNumber = null;
            String busDeviceId = null;
            Long conductorId = null;
            String conductorName = null;
            String routeName = null;
            String busStopName = null;
            String busStopLocation = null;

            // Get bus info and conductor
            if (child.getBusId() != null) {
                Bus bus = transportService.getBusById(child.getBusId());
                if (bus != null) {
                    busPlateNumber = bus.getPlateNumber();
                    busDeviceId = bus.getDeviceId();
                    conductorId = bus.getConductorId();
                    if (conductorId != null) {
                        Conductor conductor = accountsService.getConductorById(conductorId);
                        if (conductor != null) {
                            conductorName = conductor.getFullName();
                        }
                    }
                }
            }

            // Get route info
            if (child.getRouteId() != null) {
                Route route = transportService.getRouteById(child.getRouteId());
                if (route != null) {
                    routeName = route.getName();
                }
            }

            // Get bus stop info
            if (child.getBusStopId() != null) {
                BusStop busStop = transportService.getBusStopById(child.getBusStopId());
                if (busStop != null) {
                    busStopName = busStop.getName();
                    busStopLocation = busStop.getAddress();
                }
            }

            enrichedChildren.add(ChildDetailDto.fromChild(
                child, busPlateNumber, busDeviceId, conductorId, conductorName, routeName, busStopName, busStopLocation
            ));
        }

        return ResponseEntity.ok(new ApiResponse<>(
            "Children with details retrieved successfully",
            enrichedChildren
        ));
    }

    /**
     * Get a specific child with enriched data (admin).
     * GET /api/v1/children/admin/details/{childId}
     *
     * Returns child with bus, route, and bus stop names.
     *
     * @param childId The child ID
     * @return Enriched child data
     */
    @GetMapping("/admin/details/{childId}")
    public ResponseEntity<ApiResponse<ChildDetailDto>> getChildWithDetails(@PathVariable String childId) {
        Child child = studentsService.getChildById(childId);

        if (child == null) {
            throw new IllegalArgumentException("Child not found with ID: " + childId);
        }

        String busPlateNumber = null;
        String busDeviceId = null;
        Long conductorId = null;
        String conductorName = null;
        String routeName = null;
        String busStopName = null;
        String busStopLocation = null;

        // Get bus info and conductor
        if (child.getBusId() != null) {
            Bus bus = transportService.getBusById(child.getBusId());
            if (bus != null) {
                busPlateNumber = bus.getPlateNumber();
                busDeviceId = bus.getDeviceId();
                conductorId = bus.getConductorId();
                if (conductorId != null) {
                    Conductor conductor = accountsService.getConductorById(conductorId);
                    if (conductor != null) {
                        conductorName = conductor.getFullName();
                    }
                }
            }
        }

        // Get route info
        if (child.getRouteId() != null) {
            Route route = transportService.getRouteById(child.getRouteId());
            if (route != null) {
                routeName = route.getName();
            }
        }

        // Get bus stop info
        if (child.getBusStopId() != null) {
            BusStop busStop = transportService.getBusStopById(child.getBusStopId());
            if (busStop != null) {
                busStopName = busStop.getName();
                busStopLocation = busStop.getAddress();
            }
        }

        ChildDetailDto enrichedChild = ChildDetailDto.fromChild(
            child, busPlateNumber, busDeviceId, conductorId, conductorName, routeName, busStopName, busStopLocation
        );

        return ResponseEntity.ok(new ApiResponse<>(
            "Child with details retrieved successfully",
            enrichedChild
        ));
    }

    /**
     * Get all children for a parent (path variable version).
     * GET /api/v1/children/parent/{parentId}
     *
     * @param parentId The parent ID
     * @return List of children
     */
    @GetMapping("/parent/{parentId}")
    public ResponseEntity<ApiResponse<List<Child>>> getChildrenByParent(@PathVariable Long parentId) {
        List<Child> children = studentsService.getChildrenForParent(parentId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Children retrieved successfully",
            children
        ));
    }

    /**
     * Get a specific child by ID.
     * GET /api/v1/children/{childId}
     *
     * @param childId The child ID
     * @return The child
     */
    @GetMapping("/{childId}")
    public ResponseEntity<ApiResponse<Child>> getChild(@PathVariable String childId) {
        Child child = studentsService.getChildById(childId);

        if (child == null) {
            throw new IllegalArgumentException("Child not found with ID: " + childId);
        }

        return ResponseEntity.ok(new ApiResponse<>(
            "Child retrieved successfully",
            child
        ));
    }

    /**
     * Create a new child.
     * POST /api/v1/children
     *
     * Request body:
     * {
     *   "fullName": "John Doe",
     *   "birthDate": "2015-01-15",
     *   "gender": "MALE",
     *   "grade": "Grade 3",
     *   "parentId": 1
     * }
     *
     * @param child The child to create
     * @return The created child
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Child>> createChild(@RequestBody Child child) {
        if (child.getFullName() == null || child.getFullName().trim().isEmpty()) {
            throw new IllegalArgumentException("Full name is required");
        }
        // Parent ID is optional for now.

        Child created = studentsService.createChild(child);

        return ResponseEntity.status(HttpStatus.CREATED).body(new ApiResponse<>(
            "Child created successfully",
            created
        ));
    }

    /**
     * Update an existing child.
     * PUT /api/v1/children/{childId}
     *
     * @param childId The child ID
     * @param child The updated child data
     * @return The updated child
     */
    @PutMapping("/{childId}")
    public ResponseEntity<ApiResponse<Child>> updateChild(
            @PathVariable String childId,
            @RequestBody Child child) {

        Child updated = studentsService.updateChild(childId, child);

        return ResponseEntity.ok(new ApiResponse<>(
            "Child updated successfully",
            updated
        ));
    }

    /**
     * Delete a child.
     * DELETE /api/v1/children/{childId}
     *
     * @param childId The child ID
     * @return Success message
     */
    @DeleteMapping("/{childId}")
    public ResponseEntity<ApiResponse<Void>> deleteChild(@PathVariable String childId) {
        studentsService.deleteChild(childId);

        return ResponseEntity.ok(new ApiResponse<>(
            "Child deleted successfully",
            null
        ));
    }

    // ── Absence sub-resource ──────────────────────────────────────────────────

    /**
     * Get all absences for a child.
     * GET /api/v1/children/{childId}/absences
     */
    @GetMapping("/{childId}/absences")
    public ResponseEntity<ApiResponse<List<Absence>>> getChildAbsences(@PathVariable String childId) {
        List<Absence> absences = studentsService.getAbsencesForChild(childId);
        return ResponseEntity.ok(new ApiResponse<>("Absences retrieved successfully", absences));
    }

    /**
     * Create an absence for a child.
     * POST /api/v1/children/{childId}/absences
     *
     * Body: { "parentId": 1, "absenceType": "MORNING|EVENING|MULTIPLE_DAYS",
     *         "startDate": "yyyy-MM-dd", "endDate": "yyyy-MM-dd" }
     */
    @PostMapping("/{childId}/absences")
    public ResponseEntity<ApiResponse<Absence>> createAbsence(
            @PathVariable String childId,
            @RequestBody Absence absence) {
        absence.setChildId(childId);
        Absence created = studentsService.createAbsence(absence);
        return ResponseEntity.status(HttpStatus.CREATED).body(
            new ApiResponse<>("Absence created successfully", created)
        );
    }

    /**
     * Update (edit) an existing absence.
     * PUT /api/v1/children/{childId}/absences/{absenceId}
     *
     * Body: { "absenceType": "MORNING|EVENING|MULTIPLE_DAYS",
     *         "startDate": "yyyy-MM-dd", "endDate": "yyyy-MM-dd" }
     */
    @PutMapping("/{childId}/absences/{absenceId}")
    public ResponseEntity<ApiResponse<Absence>> updateAbsence(
            @PathVariable String childId,
            @PathVariable Long absenceId,
            @RequestBody Absence absence) {
        absence.setChildId(childId);
        Absence updated = studentsService.updateAbsence(absenceId, absence);
        return ResponseEntity.ok(new ApiResponse<>("Absence updated successfully", updated));
    }

    /**
     * Delete (cancel) an absence.
     * DELETE /api/v1/children/{childId}/absences/{absenceId}
     */
    @DeleteMapping("/{childId}/absences/{absenceId}")
    public ResponseEntity<ApiResponse<Void>> deleteAbsence(
            @PathVariable String childId,
            @PathVariable Long absenceId) {
        studentsService.deleteAbsence(absenceId);
        return ResponseEntity.ok(new ApiResponse<>("Absence cancelled successfully", null));
    }

    // ── Child photo ───────────────────────────────────────────────────────────

    private static final String CHILD_PHOTO_DIR = "uploads/child-photos/";
    private static final long MAX_PHOTO_SIZE = 5 * 1024 * 1024; // 5 MB

    /**
     * Upload or replace a child's profile photo.
     * PATCH /api/v1/children/{childId}/photo
     */
    @PatchMapping(value = "/{childId}/photo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<String>> uploadChildPhoto(
            @PathVariable String childId,
            @RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) throw new IllegalArgumentException("File is empty");
        if (file.getSize() > MAX_PHOTO_SIZE) throw new IllegalArgumentException("File size exceeds 5MB");

        Child child = studentsService.getChildById(childId);
        if (child == null) throw new IllegalArgumentException("Child not found: " + childId);

        try {
            File dir = new File(CHILD_PHOTO_DIR);
            if (!dir.exists()) dir.mkdirs();

            String original = file.getOriginalFilename();
            String ext = (original != null && original.contains("."))
                    ? original.substring(original.lastIndexOf(".")) : ".jpg";
            String filename = UUID.randomUUID() + ext;
            Path dest = Paths.get(CHILD_PHOTO_DIR + filename);
            Files.copy(file.getInputStream(), dest, StandardCopyOption.REPLACE_EXISTING);

            String photoUrl = "/" + CHILD_PHOTO_DIR + filename;
            child.setPhotoUrl(photoUrl);
            studentsService.updateChild(childId, child);

            return ResponseEntity.ok(new ApiResponse<>("Photo updated", photoUrl));
        } catch (Exception e) {
            throw new RuntimeException("Failed to save photo: " + e.getMessage());
        }
    }

    /**
     * Get a child's profile photo bytes.
     * GET /api/v1/children/{childId}/photo
     */
    @GetMapping("/{childId}/photo")
    public ResponseEntity<byte[]> getChildPhoto(@PathVariable String childId) {
        Child child = studentsService.getChildById(childId);
        if (child == null) throw new IllegalArgumentException("Child not found: " + childId);

        String photoUrl = child.getPhotoUrl();
        if (photoUrl == null || photoUrl.isBlank()) {
            return ResponseEntity.notFound().build();
        }

        try {
            String path = photoUrl.startsWith("/") ? photoUrl.substring(1) : photoUrl;
            byte[] data = Files.readAllBytes(Paths.get(path));
            return ResponseEntity.ok()
                    .contentType(MediaType.IMAGE_JPEG)
                    .body(data);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}
