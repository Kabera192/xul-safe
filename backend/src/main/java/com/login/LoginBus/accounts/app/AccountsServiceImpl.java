package com.login.LoginBus.accounts.app;

import com.login.LoginBus.accounts.domain.Conductor;
import com.login.LoginBus.accounts.domain.ConductorStatus;
import com.login.LoginBus.accounts.domain.EmergencyContact;
import com.login.LoginBus.accounts.domain.Parent;
import com.login.LoginBus.accounts.domain.User;
import com.login.LoginBus.accounts.domain.UserRole;
import com.login.LoginBus.accounts.infra.ConductorJpaEntity;
import com.login.LoginBus.accounts.infra.ConductorRepository;
import com.login.LoginBus.accounts.infra.EmergencyContactJpaEntity;
import com.login.LoginBus.accounts.infra.EmergencyContactRepository;
import com.login.LoginBus.accounts.infra.UserJpaEntity;
import com.login.LoginBus.accounts.infra.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Service implementation for Accounts module.
 * Implements both AccountsService and AccountsPublicService.
 */
@Service
public class AccountsServiceImpl implements AccountsService, AccountsPublicService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ConductorRepository conductorRepository;

    @Autowired
    private EmergencyContactRepository emergencyContactRepository;

    // ========== User Operations ==========

    @Override
    public User getUserById(Long userId) {
        Optional<UserJpaEntity> entityOpt = userRepository.findById(userId);
        return entityOpt.map(UserJpaEntity::toDomain).orElse(null);
    }

    @Override
    public User getUserByEmail(String email) {
        Optional<UserJpaEntity> entityOpt = userRepository.findByEmail(email);
        return entityOpt.map(UserJpaEntity::toDomain).orElse(null);
    }

    @Override
    @Transactional
    public User createUser(User user) {
        // Validate email is unique
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new IllegalArgumentException("Email already exists");
        }

        // Always force PARENT on self-registration — never trust a client-supplied role.
        user.setRole(UserRole.PARENT);

        // Set creation timestamp
        if (user.getCreatedAt() == null) {
            user.setCreatedAt(System.currentTimeMillis());
        }

        UserJpaEntity entity = UserJpaEntity.fromDomain(user);
        UserJpaEntity saved = userRepository.save(entity);

        return saved.toDomain();
    }

    @Override
    @Transactional
    public User updateUser(Long userId, User user) {
        Optional<UserJpaEntity> existingOpt = userRepository.findById(userId);

        if (existingOpt.isEmpty()) {
            throw new IllegalArgumentException("User not found with ID: " + userId);
        }

        UserJpaEntity existing = existingOpt.get();

        // Update fields if provided
        if (user.getFirstName() != null) {
            existing.setFirstName(user.getFirstName());
        }
        if (user.getLastName() != null) {
            existing.setLastName(user.getLastName());
        }
        if (user.getPhoneNumber() != null) {
            existing.setPhoneNumber(user.getPhoneNumber());
        }
        if (user.getPhotoUrl() != null) {
            existing.setPhotoUrl(user.getPhotoUrl());
        }
        if (user.getPassword() != null) {
            existing.setPassword(user.getPassword());
        }
        // Don't update email (use separate method)

        UserJpaEntity saved = userRepository.save(existing);
        return saved.toDomain();
    }

    @Override
    public boolean userExists(Long userId) {
        return userRepository.existsById(userId);
    }

    @Override
    public boolean emailExists(String email) {
        return userRepository.existsByEmail(email);
    }

    @Override
    public boolean userExists(String email) {
        return userRepository.existsByEmail(email);
    }

    // ========== Conductor Operations ==========

    @Override
    public Conductor getConductorById(Long conductorId) {
        Optional<ConductorJpaEntity> entityOpt = conductorRepository.findById(conductorId);
        return entityOpt.map(ConductorJpaEntity::toDomain).orElse(null);
    }

    @Override
    public List<Conductor> getActiveConductors() {
        List<ConductorJpaEntity> entities = conductorRepository.findByStatus(ConductorStatus.ACTIVE);
        return entities.stream()
            .map(ConductorJpaEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    public List<Conductor> getAllConductors() {
        List<ConductorJpaEntity> entities = conductorRepository.findAll();
        return entities.stream()
            .map(ConductorJpaEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public Conductor createConductor(Conductor conductor) {
        if (conductor.getFullName() == null || conductor.getFullName().trim().isEmpty()) {
            throw new IllegalArgumentException("Full name is required");
        }
        if (conductor.getPhoneNumber() == null || conductor.getPhoneNumber().trim().isEmpty()) {
            throw new IllegalArgumentException("Phone number is required");
        }
        Optional<ConductorJpaEntity> existing = conductorRepository.findByPhoneNumber(conductor.getPhoneNumber());
        if (existing.isPresent()) {
            throw new IllegalArgumentException("Conductor with this phone number already exists");
        }
        if (conductor.getStatus() == null) {
            conductor.setStatus(ConductorStatus.ACTIVE);
        }
        if (conductor.getCreatedAt() == null) {
            conductor.setCreatedAt(System.currentTimeMillis());
        }

        ConductorJpaEntity entity = ConductorJpaEntity.fromDomain(conductor);
        ConductorJpaEntity saved = conductorRepository.save(entity);
        return saved.toDomain();
    }

    @Override
    @Transactional
    public Conductor updateConductor(Long conductorId, Conductor conductor) {
        Optional<ConductorJpaEntity> existingOpt = conductorRepository.findById(conductorId);
        if (existingOpt.isEmpty()) {
            throw new IllegalArgumentException("Conductor not found with ID: " + conductorId);
        }

        ConductorJpaEntity existing = existingOpt.get();

        if (conductor.getFullName() != null) {
            existing.setFullName(conductor.getFullName());
        }
        if (conductor.getPhoneNumber() != null) {
            Optional<ConductorJpaEntity> byPhone = conductorRepository.findByPhoneNumber(conductor.getPhoneNumber());
            if (byPhone.isPresent() && !byPhone.get().getId().equals(conductorId)) {
                throw new IllegalArgumentException("Conductor with this phone number already exists");
            }
            existing.setPhoneNumber(conductor.getPhoneNumber());
        }
        if (conductor.getEmail() != null) {
            existing.setEmail(conductor.getEmail());
        }
        if (conductor.getGender() != null) {
            existing.setGender(conductor.getGender());
        }
        if (conductor.getAge() != null) {
            existing.setAge(conductor.getAge());
        }
        if (conductor.getDriverId() != null) {
            existing.setDriverId(conductor.getDriverId());
        }
        if (conductor.getLicenceNumber() != null) {
            existing.setLicenceNumber(conductor.getLicenceNumber());
        }
        if (conductor.getLicenceType() != null) {
            existing.setLicenceType(conductor.getLicenceType());
        }
        if (conductor.getLicenceExpiry() != null) {
            existing.setLicenceExpiry(conductor.getLicenceExpiry());
        }
        if (conductor.getExperience() != null) {
            existing.setExperience(conductor.getExperience());
        }
        if (conductor.getPhotoUrl() != null) {
            existing.setPhotoUrl(conductor.getPhotoUrl());
        }
        if (conductor.getStatus() != null) {
            existing.setStatus(conductor.getStatus());
        }

        ConductorJpaEntity saved = conductorRepository.save(existing);
        return saved.toDomain();
    }

    @Override
    @Transactional
    public void deleteConductor(Long conductorId) {
        if (!conductorRepository.existsById(conductorId)) {
            throw new IllegalArgumentException("Conductor not found with ID: " + conductorId);
        }
        conductorRepository.deleteById(conductorId);
    }

    // ========== AccountsPublicService Implementation ==========

    @Override
    public Parent getParentById(Long parentId) {
        // In the current implementation, parent is just a user
        // So we return parent info from user
        User user = getUserById(parentId);
        if (user == null) {
            return null;
        }

        // Convert User to Parent domain object
        Parent parent = new Parent();
        parent.setId(user.getId());
        parent.setUserId(user.getId());
        parent.setPhoneNumber(user.getPhoneNumber());
        // Parent doesn't have address in current schema, set as null
        parent.setAddress(null);
        parent.setCreatedAt(user.getCreatedAt());

        return parent;
    }

    @Override
    public Parent getParentByUserId(Long userId) {
        return getParentById(userId);
    }

    // ========== Emergency Contact Operations ==========

    @Override
    public List<EmergencyContact> getEmergencyContactsByParent(Long parentId) {
        List<EmergencyContactJpaEntity> entities = emergencyContactRepository.findByParentId(parentId);
        return entities.stream()
            .map(EmergencyContactJpaEntity::toDomain)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public EmergencyContact createEmergencyContact(EmergencyContact contact) {
        // Set creation timestamp
        if (contact.getCreatedAt() == null) {
            contact.setCreatedAt(System.currentTimeMillis());
        }

        EmergencyContactJpaEntity entity = EmergencyContactJpaEntity.fromDomain(contact);
        EmergencyContactJpaEntity saved = emergencyContactRepository.save(entity);

        return saved.toDomain();
    }

    @Override
    @Transactional
    public EmergencyContact updateEmergencyContact(Long contactId, EmergencyContact contact) {
        Optional<EmergencyContactJpaEntity> existingOpt = emergencyContactRepository.findById(contactId);

        if (existingOpt.isEmpty()) {
            throw new IllegalArgumentException("Emergency contact not found with ID: " + contactId);
        }

        EmergencyContactJpaEntity existing = existingOpt.get();

        // Update fields
        existing.setPhoneNumber(contact.getPhoneNumber());
        existing.setLabel(contact.getLabel());

        EmergencyContactJpaEntity saved = emergencyContactRepository.save(existing);
        return saved.toDomain();
    }

    @Override
    @Transactional
    public void deleteEmergencyContact(Long parentId, Long contactId) {
        Optional<EmergencyContactJpaEntity> existingOpt = emergencyContactRepository.findById(contactId);

        if (existingOpt.isEmpty()) {
            throw new IllegalArgumentException("Emergency contact not found with ID: " + contactId);
        }

        EmergencyContactJpaEntity existing = existingOpt.get();

        // Verify the contact belongs to the parent
        if (!existing.getParentId().equals(parentId)) {
            throw new IllegalArgumentException("Contact does not belong to this parent");
        }

        emergencyContactRepository.deleteById(contactId);
    }
}
