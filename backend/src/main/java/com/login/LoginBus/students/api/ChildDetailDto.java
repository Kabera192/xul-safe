package com.login.LoginBus.students.api;

import com.login.LoginBus.students.domain.Child;
import com.login.LoginBus.students.domain.Gender;

/**
 * DTO for returning enriched child data with related entity names.
 * Used by admin endpoints to display child with bus, route, and stop info.
 */
public class ChildDetailDto {

    private String id;
    private String fullName;
    private String birthDate;
    private Gender gender;
    private String grade;
    private String photoUrl;
    private Long parentId;
    private Long busId;
    private String busPlateNumber;
    private String busDeviceId;
    private Long conductorId;
    private String conductorName;
    private Long routeId;
    private String routeName;
    private String busStopId;
    private String busStopName;
    private String busStopLocation;
    private Long createdAt;

    public ChildDetailDto() {
    }

    /**
     * Create DTO from domain entity with related entity names.
     */
    public static ChildDetailDto fromChild(Child child, String busPlateNumber, String busDeviceId,
                                           Long conductorId, String conductorName,
                                           String routeName, String busStopName, String busStopLocation) {
        ChildDetailDto dto = new ChildDetailDto();
        dto.id = child.getId();
        dto.fullName = child.getFullName();
        dto.birthDate = child.getBirthDate();
        dto.gender = child.getGender();
        dto.grade = child.getGrade();
        dto.photoUrl = child.getPhotoUrl();
        dto.parentId = child.getParentId();
        dto.busId = child.getBusId();
        dto.busPlateNumber = busPlateNumber;
        dto.busDeviceId = busDeviceId;
        dto.conductorId = conductorId;
        dto.conductorName = conductorName;
        dto.routeId = child.getRouteId();
        dto.routeName = routeName;
        dto.busStopId = child.getBusStopId();
        dto.busStopName = busStopName;
        dto.busStopLocation = busStopLocation;
        dto.createdAt = child.getCreatedAt();
        return dto;
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

    public Long getBusId() {
        return busId;
    }

    public void setBusId(Long busId) {
        this.busId = busId;
    }

    public String getBusPlateNumber() {
        return busPlateNumber;
    }

    public void setBusPlateNumber(String busPlateNumber) {
        this.busPlateNumber = busPlateNumber;
    }

    public String getBusDeviceId() {
        return busDeviceId;
    }

    public void setBusDeviceId(String busDeviceId) {
        this.busDeviceId = busDeviceId;
    }

    public Long getConductorId() {
        return conductorId;
    }

    public void setConductorId(Long conductorId) {
        this.conductorId = conductorId;
    }

    public String getConductorName() {
        return conductorName;
    }

    public void setConductorName(String conductorName) {
        this.conductorName = conductorName;
    }

    public Long getRouteId() {
        return routeId;
    }

    public void setRouteId(Long routeId) {
        this.routeId = routeId;
    }

    public String getRouteName() {
        return routeName;
    }

    public void setRouteName(String routeName) {
        this.routeName = routeName;
    }

    public String getBusStopId() {
        return busStopId;
    }

    public void setBusStopId(String busStopId) {
        this.busStopId = busStopId;
    }

    public String getBusStopName() {
        return busStopName;
    }

    public void setBusStopName(String busStopName) {
        this.busStopName = busStopName;
    }

    public String getBusStopLocation() {
        return busStopLocation;
    }

    public void setBusStopLocation(String busStopLocation) {
        this.busStopLocation = busStopLocation;
    }

    public Long getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Long createdAt) {
        this.createdAt = createdAt;
    }
}
