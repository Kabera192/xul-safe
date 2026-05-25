package com.login.LoginBus.accounts.infra;

import com.login.LoginBus.accounts.domain.Driver;
import jakarta.persistence.*;

@Entity
@Table(name = "drivers")
public class DriverJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "created_at")
    private Long createdAt;

    public DriverJpaEntity() {}

    public Driver toDomain() {
        return new Driver(this.id, this.userId, this.createdAt);
    }

    public static DriverJpaEntity fromDomain(Driver driver) {
        DriverJpaEntity entity = new DriverJpaEntity();
        entity.setId(driver.getId());
        entity.setUserId(driver.getUserId());
        entity.setCreatedAt(driver.getCreatedAt());
        return entity;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public Long getCreatedAt() { return createdAt; }
    public void setCreatedAt(Long createdAt) { this.createdAt = createdAt; }
}
