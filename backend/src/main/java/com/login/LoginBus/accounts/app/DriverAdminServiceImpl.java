package com.login.LoginBus.accounts.app;

import com.login.LoginBus.accounts.api.DriverAdminDto;
import com.login.LoginBus.accounts.domain.ConductorStatus;
import com.login.LoginBus.accounts.domain.UserRole;
import com.login.LoginBus.accounts.infra.ConductorJpaEntity;
import com.login.LoginBus.accounts.infra.ConductorRepository;
import com.login.LoginBus.accounts.infra.UserJpaEntity;
import com.login.LoginBus.accounts.infra.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class DriverAdminServiceImpl implements DriverAdminService {

    private final UserRepository userRepository;
    private final ConductorRepository conductorRepository;
    private final PasswordEncoder passwordEncoder;

    public DriverAdminServiceImpl(UserRepository userRepository,
                                  ConductorRepository conductorRepository,
                                  PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.conductorRepository = conductorRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional(readOnly = true)
    public List<DriverAdminDto> getAllDrivers() {
        return conductorRepository.findAll().stream()
                .map(this::toDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public DriverAdminDto getDriverById(Long conductorId) {
        ConductorJpaEntity conductor = conductorRepository.findById(conductorId)
                .orElseThrow(() -> new IllegalArgumentException("Driver not found with id: " + conductorId));
        return toDto(conductor);
    }

    @Override
    @Transactional
    public DriverAdminDto createDriver(DriverAdminDto dto) {
        if (dto.getEmail() == null || dto.getEmail().isBlank()) {
            throw new IllegalArgumentException("Email is required");
        }
        if (dto.getPassword() == null || dto.getPassword().isBlank()) {
            throw new IllegalArgumentException("Password is required");
        }
        if (dto.getPhoneNumber() == null || dto.getPhoneNumber().isBlank()) {
            throw new IllegalArgumentException("Phone number is required");
        }
        if (dto.getFullName() == null || dto.getFullName().isBlank()) {
            throw new IllegalArgumentException("Full name is required");
        }
        if (userRepository.existsByEmail(dto.getEmail().trim().toLowerCase())) {
            throw new IllegalArgumentException("Email already registered");
        }
        if (conductorRepository.findByPhoneNumber(dto.getPhoneNumber().trim()).isPresent()) {
            throw new IllegalArgumentException("A driver with this phone number already exists");
        }

        // 1. Create user account with DRIVER role
        UserJpaEntity user = new UserJpaEntity();
        user.setEmail(dto.getEmail().trim().toLowerCase());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setFirstName(dto.getFirstName() != null ? dto.getFirstName() : dto.getFullName().split(" ")[0]);
        user.setLastName(dto.getLastName() != null ? dto.getLastName() : extractLastName(dto.getFullName()));
        user.setPhoneNumber(dto.getPhoneNumber().trim());
        user.setRole(UserRole.DRIVER);
        user.setPhotoUrl(dto.getPhotoUrl());
        UserJpaEntity savedUser = userRepository.save(user);

        // 2. Create conductor profile linked to that user
        ConductorJpaEntity conductor = new ConductorJpaEntity();
        conductor.setFullName(dto.getFullName());
        conductor.setPhoneNumber(dto.getPhoneNumber().trim());
        conductor.setEmail(dto.getEmail().trim().toLowerCase());
        conductor.setGender(dto.getGender());
        conductor.setAge(dto.getAge());
        conductor.setDriverId(dto.getDriverId());
        conductor.setLicenceNumber(dto.getLicenceNumber());
        conductor.setLicenceType(dto.getLicenceType());
        conductor.setLicenceExpiry(dto.getLicenceExpiry());
        conductor.setExperience(dto.getExperience());
        conductor.setPhotoUrl(dto.getPhotoUrl());
        conductor.setStatus(parseStatus(dto.getStatus(), ConductorStatus.ACTIVE));
        conductor.setUserId(savedUser.getId());
        ConductorJpaEntity savedConductor = conductorRepository.save(conductor);

        return toDto(savedConductor, savedUser);
    }

    @Override
    @Transactional
    public DriverAdminDto updateDriver(Long conductorId, DriverAdminDto dto) {
        ConductorJpaEntity conductor = conductorRepository.findById(conductorId)
                .orElseThrow(() -> new IllegalArgumentException("Driver not found with id: " + conductorId));

        // Update conductor profile fields
        if (dto.getFullName() != null) conductor.setFullName(dto.getFullName());
        if (dto.getGender() != null) conductor.setGender(dto.getGender());
        if (dto.getAge() != null) conductor.setAge(dto.getAge());
        if (dto.getDriverId() != null) conductor.setDriverId(dto.getDriverId());
        if (dto.getLicenceNumber() != null) conductor.setLicenceNumber(dto.getLicenceNumber());
        if (dto.getLicenceType() != null) conductor.setLicenceType(dto.getLicenceType());
        if (dto.getLicenceExpiry() != null) conductor.setLicenceExpiry(dto.getLicenceExpiry());
        if (dto.getExperience() != null) conductor.setExperience(dto.getExperience());
        if (dto.getPhotoUrl() != null) conductor.setPhotoUrl(dto.getPhotoUrl());
        if (dto.getStatus() != null) conductor.setStatus(parseStatus(dto.getStatus(), conductor.getStatus()));
        if (dto.getPhoneNumber() != null) {
            // Check phone uniqueness (skip if same conductor)
            conductorRepository.findByPhoneNumber(dto.getPhoneNumber().trim())
                    .ifPresent(existing -> {
                        if (!existing.getId().equals(conductorId)) {
                            throw new IllegalArgumentException("Phone number already in use");
                        }
                    });
            conductor.setPhoneNumber(dto.getPhoneNumber().trim());
        }
        ConductorJpaEntity savedConductor = conductorRepository.save(conductor);

        // Update linked user account if one exists
        UserJpaEntity user = null;
        if (conductor.getUserId() != null) {
            user = userRepository.findById(conductor.getUserId()).orElse(null);
            if (user != null) {
                if (dto.getFirstName() != null) user.setFirstName(dto.getFirstName());
                if (dto.getLastName() != null) user.setLastName(dto.getLastName());
                if (dto.getPhoneNumber() != null) user.setPhoneNumber(dto.getPhoneNumber().trim());
                if (dto.getPhotoUrl() != null) user.setPhotoUrl(dto.getPhotoUrl());
                // Only update password when explicitly provided
                if (dto.getPassword() != null && !dto.getPassword().isBlank()) {
                    user.setPassword(passwordEncoder.encode(dto.getPassword()));
                }
                user = userRepository.save(user);
            }
        }

        return toDto(savedConductor, user);
    }

    @Override
    @Transactional
    public void deleteDriver(Long conductorId) {
        ConductorJpaEntity conductor = conductorRepository.findById(conductorId)
                .orElseThrow(() -> new IllegalArgumentException("Driver not found with id: " + conductorId));

        Long userId = conductor.getUserId();
        conductorRepository.deleteById(conductorId);

        if (userId != null) {
            userRepository.deleteById(userId);
        }
    }

    // ── Helpers ────────────────────────────────────────────────────────────────

    private DriverAdminDto toDto(ConductorJpaEntity conductor) {
        UserJpaEntity user = null;
        if (conductor.getUserId() != null) {
            user = userRepository.findById(conductor.getUserId()).orElse(null);
        }
        return toDto(conductor, user);
    }

    private DriverAdminDto toDto(ConductorJpaEntity conductor, UserJpaEntity user) {
        DriverAdminDto dto = new DriverAdminDto();
        dto.setId(conductor.getId());
        dto.setUserId(conductor.getUserId());
        dto.setFullName(conductor.getFullName());
        dto.setPhoneNumber(conductor.getPhoneNumber());
        dto.setEmail(conductor.getEmail());
        dto.setGender(conductor.getGender());
        dto.setAge(conductor.getAge());
        dto.setDriverId(conductor.getDriverId());
        dto.setLicenceNumber(conductor.getLicenceNumber());
        dto.setLicenceType(conductor.getLicenceType());
        dto.setLicenceExpiry(conductor.getLicenceExpiry());
        dto.setExperience(conductor.getExperience());
        dto.setPhotoUrl(conductor.getPhotoUrl());
        dto.setStatus(conductor.getStatus() != null ? conductor.getStatus().name() : null);
        dto.setCreatedAt(conductor.getCreatedAt());
        // password is never returned
        if (user != null) {
            dto.setFirstName(user.getFirstName());
            dto.setLastName(user.getLastName());
        }
        return dto;
    }

    private ConductorStatus parseStatus(String status, ConductorStatus fallback) {
        if (status == null) return fallback;
        try {
            return ConductorStatus.valueOf(status.toUpperCase());
        } catch (IllegalArgumentException e) {
            return fallback;
        }
    }

    private String extractLastName(String fullName) {
        if (fullName == null || !fullName.contains(" ")) return "";
        return fullName.substring(fullName.indexOf(' ') + 1);
    }
}
