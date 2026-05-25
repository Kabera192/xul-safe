package com.login.LoginBus.accounts.infra;

import com.login.LoginBus.accounts.domain.Parent;
import jakarta.persistence.*;

@Entity
@Table(name = "parents")
public class ParentJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(name = "address")
    private String address;

    @Column(name = "created_at")
    private Long createdAt;

    public ParentJpaEntity() {}

    public Parent toDomain() {
        return new Parent(this.id, this.userId, this.phoneNumber, this.address, this.createdAt);
    }

    public static ParentJpaEntity fromDomain(Parent parent) {
        ParentJpaEntity entity = new ParentJpaEntity();
        entity.setId(parent.getId());
        entity.setUserId(parent.getUserId());
        entity.setPhoneNumber(parent.getPhoneNumber());
        entity.setAddress(parent.getAddress());
        entity.setCreatedAt(parent.getCreatedAt());
        return entity;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public Long getCreatedAt() { return createdAt; }
    public void setCreatedAt(Long createdAt) { this.createdAt = createdAt; }
}
