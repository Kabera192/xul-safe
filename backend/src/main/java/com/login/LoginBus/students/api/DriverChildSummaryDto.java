package com.login.LoginBus.students.api;

/**
 * Summary DTO for a child on the driver's bus.
 * Field names use camelCase to match Flutter ChildModel.fromApiResponse:
 *   id, fullName, grade, gender, photoUrl, busStopId
 */
public class DriverChildSummaryDto {

    // Flutter reads 'id'
    private String id;

    // Flutter reads 'fullName'
    private String fullName;

    private String grade;

    private String gender;

    // Flutter reads 'photoUrl'
    private String photoUrl;

    // Flutter reads 'busStopId' — the single stop this child boards/alights at
    private String busStopId;

    public DriverChildSummaryDto() {}

    public DriverChildSummaryDto(String id, String fullName, String grade, String gender,
                                  String photoUrl, String busStopId) {
        this.id = id;
        this.fullName = fullName;
        this.grade = grade;
        this.gender = gender;
        this.photoUrl = photoUrl;
        this.busStopId = busStopId;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    public String getBusStopId() { return busStopId; }
    public void setBusStopId(String busStopId) { this.busStopId = busStopId; }
}
