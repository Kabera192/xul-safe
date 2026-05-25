package com.login.LoginBus.students.api;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Response DTO that combines a child's basic info with their two-step
 * driver-confirmed attendance status for a specific session (MORNING or AFTERNOON).
 *
 * Each session has two events:
 *   MORNING  : boarded (got on bus) → droppedOff (arrived at school)
 *   AFTERNOON: boarded (left school on bus) → droppedOff (arrived at bus stop / home)
 */
public class AttendanceWithChildDto {

    @JsonProperty("childId")
    private String childId;

    @JsonProperty("childName")
    private String childName;

    @JsonProperty("grade")
    private String grade;

    @JsonProperty("gender")
    private String gender;

    @JsonProperty("photoUrl")
    private String photoUrl;

    /** "MORNING" or "AFTERNOON" */
    @JsonProperty("session")
    private String session;

    /** true = driver confirmed the child boarded the bus */
    @JsonProperty("boarded")
    private boolean boarded;

    /** Epoch-millis of the boarding confirmation; null if not yet boarded */
    @JsonProperty("boardedAt")
    private Long boardedAt;

    /** true = driver confirmed the child was dropped off at their destination */
    @JsonProperty("droppedOff")
    private boolean droppedOff;

    /** Epoch-millis of the drop-off confirmation; null if not yet dropped off */
    @JsonProperty("droppedOffAt")
    private Long droppedOffAt;

    public AttendanceWithChildDto() {}

    public AttendanceWithChildDto(String childId, String childName, String grade, String gender,
                                   String photoUrl, String session,
                                   boolean boarded, Long boardedAt,
                                   boolean droppedOff, Long droppedOffAt) {
        this.childId = childId;
        this.childName = childName;
        this.grade = grade;
        this.gender = gender;
        this.photoUrl = photoUrl;
        this.session = session;
        this.boarded = boarded;
        this.boardedAt = boardedAt;
        this.droppedOff = droppedOff;
        this.droppedOffAt = droppedOffAt;
    }

    public String getChildId() { return childId; }
    public void setChildId(String childId) { this.childId = childId; }

    public String getChildName() { return childName; }
    public void setChildName(String childName) { this.childName = childName; }

    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }

    public String getSession() { return session; }
    public void setSession(String session) { this.session = session; }

    public boolean isBoarded() { return boarded; }
    public void setBoarded(boolean boarded) { this.boarded = boarded; }

    public Long getBoardedAt() { return boardedAt; }
    public void setBoardedAt(Long boardedAt) { this.boardedAt = boardedAt; }

    public boolean isDroppedOff() { return droppedOff; }
    public void setDroppedOff(boolean droppedOff) { this.droppedOff = droppedOff; }

    public Long getDroppedOffAt() { return droppedOffAt; }
    public void setDroppedOffAt(Long droppedOffAt) { this.droppedOffAt = droppedOffAt; }
}

