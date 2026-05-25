package com.login.LoginBus.students.infra;

import com.login.LoginBus.students.domain.AttendanceSession;
import jakarta.persistence.*;

import java.time.LocalDate;

/**
 * JPA Entity for driver-confirmed attendance records.
 * One record per (child, date, session) – upserted as the driver confirms events.
 *
 * Each session has TWO events that must be confirmed:
 *   MORNING  : boarded (got on the bus) → droppedOff (arrived at school)
 *   AFTERNOON: boarded (left school on bus) → droppedOff (arrived at bus stop)
 */
@Entity
@Table(
    name = "attendance_records",
    uniqueConstraints = {
        @UniqueConstraint(columnNames = {"child_id", "date", "session"})
    }
)
public class AttendanceJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "child_id", nullable = false)
    private String childId;

    @Column(name = "bus_id", nullable = false)
    private Long busId;

    @Column(name = "conductor_id", nullable = false)
    private Long conductorId;

    @Column(nullable = false)
    private LocalDate date;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private AttendanceSession session;

    /** true = child has boarded the bus for this session */
    @Column(name = "boarded", nullable = false, columnDefinition = "boolean default false")
    private boolean boarded = false;

    /** Epoch-millis when the driver confirmed boarding */
    @Column(name = "boarded_at")
    private Long boardedAt;

    /** true = child has been dropped off at their destination */
    @Column(name = "dropped_off", nullable = false, columnDefinition = "boolean default false")
    private boolean droppedOff = false;

    /** Epoch-millis when the driver confirmed the drop-off */
    @Column(name = "dropped_off_at")
    private Long droppedOffAt;

    @Column(name = "created_at")
    private Long createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = System.currentTimeMillis();
        }
    }

    public AttendanceJpaEntity() {}

    // ── Getters & Setters ─────────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getChildId() { return childId; }
    public void setChildId(String childId) { this.childId = childId; }

    public Long getBusId() { return busId; }
    public void setBusId(Long busId) { this.busId = busId; }

    public Long getConductorId() { return conductorId; }
    public void setConductorId(Long conductorId) { this.conductorId = conductorId; }

    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }

    public AttendanceSession getSession() { return session; }
    public void setSession(AttendanceSession session) { this.session = session; }

    public boolean isBoarded() { return boarded; }
    public void setBoarded(boolean boarded) { this.boarded = boarded; }

    public Long getBoardedAt() { return boardedAt; }
    public void setBoardedAt(Long boardedAt) { this.boardedAt = boardedAt; }

    public boolean isDroppedOff() { return droppedOff; }
    public void setDroppedOff(boolean droppedOff) { this.droppedOff = droppedOff; }

    public Long getDroppedOffAt() { return droppedOffAt; }
    public void setDroppedOffAt(Long droppedOffAt) { this.droppedOffAt = droppedOffAt; }

    public Long getCreatedAt() { return createdAt; }
    public void setCreatedAt(Long createdAt) { this.createdAt = createdAt; }
}

