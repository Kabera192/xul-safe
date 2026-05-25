package com.login.LoginBus.transport.api;

import com.login.LoginBus.shared.api.ApiResponse;
import com.login.LoginBus.transport.app.TransportService;
import com.login.LoginBus.transport.domain.Journey;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * REST controller for journey operations.
 * All endpoints use /api/v1 prefix for versioning.
 */
@RestController
@RequestMapping("/api/v1/journeys")
@CrossOrigin(origins = "*")
public class JourneyController {

    @Autowired
    private TransportService transportService;

    /**
     * Get all journeys for a parent's children.
     * POST /api/v1/journeys/parent
     *
     * Request body:
     * {
     *   "childIds": ["child1", "child2"]
     * }
     *
     * @param request Request containing list of child IDs
     * @return List of journeys
     */
    @PostMapping("/parent")
    public ResponseEntity<ApiResponse<List<Journey>>> getJourneysByParent(
            @RequestBody Map<String, List<String>> request) {

        List<String> childIds = request.get("childIds");

        if (childIds == null || childIds.isEmpty()) {
            throw new IllegalArgumentException("Child IDs are required");
        }

        List<Journey> journeys = transportService.getJourneysByChildIds(childIds);

        return ResponseEntity.ok(new ApiResponse<>(
            "Journeys retrieved successfully",
            journeys
        ));
    }

    /**
     * Get journey summary for a parent (includes monthly count).
     * POST /api/v1/journeys/parent/summary
     *
     * Request body:
     * {
     *   "childIds": ["child1", "child2"]
     * }
     *
     * Response:
     * {
     *   "message": "Summary retrieved successfully",
     *   "data": {
     *     "journeys": [...],
     *     "monthly_count": 15
     *   }
     * }
     *
     * @param request Request containing list of child IDs
     * @return Journey summary with monthly count
     */
    @PostMapping("/parent/summary")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getJourneySummary(
            @RequestBody Map<String, List<String>> request) {

        List<String> childIds = request.get("childIds");

        if (childIds == null || childIds.isEmpty()) {
            throw new IllegalArgumentException("Child IDs are required");
        }

        Map<String, Object> summary = transportService.getJourneySummaryForParent(childIds);

        return ResponseEntity.ok(new ApiResponse<>(
            "Summary retrieved successfully",
            summary
        ));
    }

    /**
     * Create sample journey data for testing.
     * POST /api/v1/journeys/sample
     *
     * Request body:
     * {
     *   "childIds": ["child1", "child2"]
     * }
     *
     * @param request Request containing list of child IDs
     * @return Success message
     */
    @PostMapping("/sample")
    public ResponseEntity<ApiResponse<Void>> createSampleJourneys(
            @RequestBody Map<String, List<String>> request) {

        List<String> childIds = request.get("childIds");

        if (childIds == null || childIds.isEmpty()) {
            throw new IllegalArgumentException("Child IDs are required");
        }

        transportService.createSampleJourneys(childIds);

        return ResponseEntity.ok(new ApiResponse<>(
            "Sample journeys created successfully",
            null
        ));
    }

    // ========== Admin Endpoints ==========

    /**
     * Get all journeys (admin).
     * GET /api/v1/journeys
     *
     * @return List of all journeys
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<Journey>>> getAllJourneys() {
        List<Journey> journeys = transportService.getAllJourneys();
        return ResponseEntity.ok(new ApiResponse<>(
            "Journeys retrieved successfully",
            journeys
        ));
    }

    /**
     * Get journeys by date range (admin).
     * GET /api/v1/journeys/range?startDate=2024-01-01&endDate=2024-01-07
     *
     * @param startDate Start date (yyyy-MM-dd)
     * @param endDate End date (yyyy-MM-dd)
     * @return List of journeys in date range
     */
    @GetMapping("/range")
    public ResponseEntity<ApiResponse<List<Journey>>> getJourneysByDateRange(
            @RequestParam String startDate,
            @RequestParam String endDate) {

        List<Journey> journeys = transportService.getJourneysByDateRange(startDate, endDate);
        return ResponseEntity.ok(new ApiResponse<>(
            "Journeys retrieved successfully",
            journeys
        ));
    }

    /**
     * Get weekly attendance data (admin).
     * GET /api/v1/journeys/attendance/weekly?weekStart=2024-01-01
     *
     * Returns attendance grouped by child with daily pickup/dropoff status.
     *
     * @param weekStart Start date of the week (yyyy-MM-dd, should be Monday)
     * @return List of attendance records
     */
    @GetMapping("/attendance/weekly")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getWeeklyAttendance(
            @RequestParam String weekStart) {

        List<Map<String, Object>> attendance = transportService.getWeeklyAttendance(weekStart);
        return ResponseEntity.ok(new ApiResponse<>(
            "Weekly attendance retrieved successfully",
            attendance
        ));
    }
}
