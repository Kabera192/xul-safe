package com.login.LoginBus.accounts.app;

import com.login.LoginBus.accounts.api.DriverAdminDto;
import java.util.List;

/**
 * Service interface for admin Driver operations.
 * A "Driver" is a user with DRIVER role that also has a linked conductor profile.
 * This is the single source of truth — conductors and drivers are the same person.
 */
public interface DriverAdminService {

    /** List all drivers with their linked conductor profiles. */
    List<DriverAdminDto> getAllDrivers();

    /** Get a single driver by conductor profile id. */
    DriverAdminDto getDriverById(Long conductorId);

    /**
     * Create a new driver atomically:
     *  1. Creates a user account with DRIVER role.
     *  2. Creates a conductor profile linked to that user.
     */
    DriverAdminDto createDriver(DriverAdminDto dto);

    /**
     * Update an existing driver's user account and conductor profile.
     * Password is only updated when explicitly provided in the dto.
     */
    DriverAdminDto updateDriver(Long conductorId, DriverAdminDto dto);

    /**
     * Delete a driver: removes both the conductor profile and the linked user account.
     */
    void deleteDriver(Long conductorId);
}
