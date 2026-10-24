package com.login.LoginBus.students.app;

import com.login.LoginBus.students.domain.Child;
import com.login.LoginBus.students.domain.Gender;
import com.login.LoginBus.students.infra.ChildJpaEntity;
import com.login.LoginBus.students.infra.ChildRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class StudentsServiceImplSingleBusTest {

    private ChildRepository childRepository;
    private StudentsServiceImpl service;

    @BeforeEach
    void setUp() {
        childRepository = mock(ChildRepository.class);
        service = new StudentsServiceImpl();
        ReflectionTestUtils.setField(service, "childRepository", childRepository);
    }

    private ChildJpaEntity entity(String id, Long parentId, Long busId) {
        ChildJpaEntity e = new ChildJpaEntity();
        e.setId(id);
        e.setFullName("Sibling " + id);
        e.setBirthDate("2015-01-01");
        e.setGender(Gender.MALE);
        e.setGrade("3");
        e.setParentId(parentId);
        e.setBusId(busId);
        return e;
    }

    @Test
    void createChild_rejectsDifferentBusThanExistingSibling() {
        when(childRepository.findByParentId(1L))
            .thenReturn(List.of(entity("sib-1", 1L, 100L)));
        when(childRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        Child newChild = new Child();
        newChild.setFullName("New Kid");
        newChild.setBirthDate("2016-01-01");
        newChild.setGender(Gender.FEMALE);
        newChild.setGrade("1");
        newChild.setParentId(1L);
        newChild.setBusId(200L); // different bus than sib-1's 100L

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
            () -> service.createChild(newChild));
        System.out.println("createChild threw: " + ex.getMessage());
    }

    @Test
    void updateChild_rejectsDifferentBusThanExistingSibling_noChangeStillValidatesExistingMismatch() {
        // Pre-existing mismatched state: sib-1 on bus 100, sib-2 (being edited) on bus 200
        ChildJpaEntity sib1 = entity("sib-1", 1L, 100L);
        ChildJpaEntity sib2 = entity("sib-2", 1L, 200L);

        when(childRepository.findById("sib-2")).thenReturn(Optional.of(sib2));
        when(childRepository.findByParentId(1L)).thenReturn(List.of(sib1, sib2));
        when(childRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // "Edit and don't change anything" -> submit sib-2 with the SAME busId (200L)
        Child incoming = new Child();
        incoming.setFullName("Sibling sib-2");
        incoming.setBirthDate("2015-01-01");
        incoming.setGender(Gender.MALE);
        incoming.setGrade("3");
        incoming.setParentId(1L);
        incoming.setBusId(200L);

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
            () -> service.updateChild("sib-2", incoming));
        System.out.println("updateChild threw: " + ex.getMessage());
    }
}
