package com.login.LoginBus.students.app;

import com.login.LoginBus.students.api.AssignChildrenToStopRequest;
import com.login.LoginBus.students.api.DriverChildSummaryDto;
import org.springframework.security.oauth2.jwt.Jwt;

import java.time.LocalDate;
import java.util.List;

public interface DriverChildrenService {
    List<DriverChildSummaryDto> getBusChildren(Jwt jwt);
    DriverChildSummaryDto getChild(Jwt jwt, String childId);
    List<DriverChildSummaryDto> getAbsentChildren(Jwt jwt, LocalDate date, String journey);
    List<DriverChildSummaryDto> getPresentChildren(Jwt jwt, LocalDate date, String journey);
    void assignChildrenToStop(Jwt jwt, Long stopId, AssignChildrenToStopRequest request);
}
