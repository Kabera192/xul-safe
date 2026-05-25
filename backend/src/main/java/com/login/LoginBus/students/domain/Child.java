package com.login.LoginBus.students.domain;

/**
 * Pure domain entity for Child.
 * Contains NO framework annotations - only business logic.
 */
public class Child {

    private String id;
    private String fullName;
    private String birthDate;
    private Gender gender;
    private String grade;
    private String photoUrl;
    private Long parentId;
    private Long busId;
    private Long routeId;
    private String busStopId;
    private Long createdAt;

    // No-arg constructor
    public Child() {
    }

    // Full constructor
    public Child(String id, String fullName, String birthDate, Gender gender,
                 String grade, String photoUrl, Long parentId, Long busId,
                 Long routeId, String busStopId, Long createdAt) {
        this.id = id;
        this.fullName = fullName;
        this.birthDate = birthDate;
        this.gender = gender;
        this.grade = grade;
        this.photoUrl = photoUrl;
        this.parentId = parentId;
        this.busId = busId;
        this.routeId = routeId;
        this.busStopId = busStopId;
        this.createdAt = createdAt;
    }

    // Business logic methods
    public String getFirstName() {
        if (fullName == null || !fullName.contains(" ")) {
            return fullName;
        }
        return fullName.split(" ")[0];
    }

    public boolean hasPhoto() {
        return photoUrl != null && !photoUrl.isEmpty();
    }

    public int getAge() {
        // TODO: Calculate age from birthDate
        // For now, return -1
        return -1;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(String birthDate) {
        this.birthDate = birthDate;
    }

    public Gender getGender() {
        return gender;
    }

    public void setGender(Gender gender) {
        this.gender = gender;
    }

    public String getGrade() {
        return grade;
    }

    public void setGrade(String grade) {
        this.grade = grade;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public Long getParentId() {
        return parentId;
    }

    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }

    public Long getBusId() {
        return busId;
    }

    public void setBusId(Long busId) {
        this.busId = busId;
    }

    public Long getRouteId() {
        return routeId;
    }

    public void setRouteId(Long routeId) {
        this.routeId = routeId;
    }

    public String getBusStopId() {
        return busStopId;
    }

    public void setBusStopId(String busStopId) {
        this.busStopId = busStopId;
    }
}
