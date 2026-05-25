import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { StudentService } from '../../services/student.service';
import { EmergencyContactService } from '../../services/emergency-contact.service';
import { ChildDetail, EmergencyContact } from '../../models';
import { environment } from '../../../environments/environment';
import { catchError, finalize, of, timeout } from 'rxjs';

interface EditableContact extends EmergencyContact {
  isEditing: boolean;
  originalPhoneNumber?: string;
  originalLabel?: string;
  isNew?: boolean;
}

@Component({
  selector: 'app-student-details',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './student-details.html',
  styleUrl: './student-details.scss',
})
export class StudentDetailsPage implements OnInit {
  private route = inject(ActivatedRoute);
  private studentService = inject(StudentService);
  private emergencyContactService = inject(EmergencyContactService);
  private cdr = inject(ChangeDetectorRef);

  student: ChildDetail | null = null;
  isLoading = false;
  errorMessage = '';

  emergencyContacts: EditableContact[] = [];
  parentEmail = '';

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (!id) {
      this.errorMessage = 'Student not found.';
      return;
    }
    this.isLoading = true;
    const fallbackTimer = window.setTimeout(() => {
      if (this.isLoading) {
        this.isLoading = false;
        this.errorMessage = 'Failed to load student. Please try again.';
        this.cdr.detectChanges();
      }
    }, 5000);
    this.studentService.getByIdWithDetails(id).pipe(
      timeout(5000),
      catchError((error) => {
        this.errorMessage = error?.message || 'Failed to load student.';
        return of(null as ChildDetail | null);
      }),
      finalize(() => {
        this.isLoading = false;
        window.clearTimeout(fallbackTimer);
        this.cdr.detectChanges();
      })
    ).subscribe((student) => {
      if (student?.photoUrl) {
        student = { ...student, photoUrl: this.normalizePhotoUrl(student.photoUrl) };
      }
      this.student = student;
      if (student?.parentId) {
        this.loadEmergencyContacts(student.parentId);
      }
      this.cdr.detectChanges();
    });
  }

  get displayName(): string {
    return this.student?.fullName ?? 'Student';
  }

  get displayGender(): string {
    return this.student?.gender ?? 'N/A';
  }

  get displayDob(): string {
    return this.student?.birthDate ?? 'N/A';
  }

  get displayGrade(): string {
    return this.student?.grade ?? 'N/A';
  }

  get conductorInitials(): string {
    const name = this.student?.conductorName;
    if (!name) {
      return 'N/A';
    }
    const parts = name.trim().split(/\s+/);
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  private loadEmergencyContacts(parentId: number): void {
    this.emergencyContactService.getByParent(parentId).pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load emergency contacts:', error);
        return of([] as EmergencyContact[]);
      })
    ).subscribe((contacts) => {
      this.emergencyContacts = contacts.map(contact => ({
        ...contact,
        isEditing: false
      }));
      this.cdr.detectChanges();
    });
  }

  addNewContact(): void {
    if (!this.student?.parentId) {
      return;
    }
    const newContact: EditableContact = {
      phoneNumber: '',
      label: '',
      parentId: this.student.parentId,
      isEditing: true,
      isNew: true
    };
    this.emergencyContacts.push(newContact);
    this.cdr.detectChanges();
  }

  editContact(index: number): void {
    const contact = this.emergencyContacts[index];
    contact.originalPhoneNumber = contact.phoneNumber;
    contact.originalLabel = contact.label;
    contact.isEditing = true;
    this.cdr.detectChanges();
  }

  saveContact(index: number): void {
    const contact = this.emergencyContacts[index];
    if (!contact.phoneNumber || !contact.label) {
      this.errorMessage = 'Phone number and label are required.';
      this.cdr.detectChanges();
      return;
    }

    if (contact.isNew) {
      this.emergencyContactService.create({
        phoneNumber: contact.phoneNumber,
        label: contact.label,
        parentId: contact.parentId
      }).pipe(
        timeout(5000),
        catchError((error) => {
          this.errorMessage = error?.message || 'Failed to create contact.';
          return of(null);
        })
      ).subscribe((saved) => {
        if (saved) {
          contact.id = saved.id;
          contact.isNew = false;
          contact.isEditing = false;
          delete contact.originalPhoneNumber;
          delete contact.originalLabel;
        }
        this.cdr.detectChanges();
      });
    } else if (contact.id) {
      this.emergencyContactService.update(contact.id, {
        phoneNumber: contact.phoneNumber,
        label: contact.label
      }).pipe(
        timeout(5000),
        catchError((error) => {
          this.errorMessage = error?.message || 'Failed to update contact.';
          return of(null);
        })
      ).subscribe((updated) => {
        if (updated) {
          contact.isEditing = false;
          delete contact.originalPhoneNumber;
          delete contact.originalLabel;
        }
        this.cdr.detectChanges();
      });
    }
  }

  cancelEdit(index: number): void {
    const contact = this.emergencyContacts[index];
    if (contact.isNew) {
      this.emergencyContacts.splice(index, 1);
    } else {
      contact.phoneNumber = contact.originalPhoneNumber || '';
      contact.label = contact.originalLabel || '';
      contact.isEditing = false;
      delete contact.originalPhoneNumber;
      delete contact.originalLabel;
    }
    this.cdr.detectChanges();
  }

  deleteContact(index: number): void {
    const contact = this.emergencyContacts[index];
    if (contact.isNew) {
      this.emergencyContacts.splice(index, 1);
      this.cdr.detectChanges();
      return;
    }

    if (!contact.id || !this.student?.parentId) {
      return;
    }

    this.emergencyContactService.delete(this.student.parentId, contact.id).pipe(
      timeout(5000),
      catchError((error) => {
        this.errorMessage = error?.message || 'Failed to delete contact.';
        return of(null);
      })
    ).subscribe(() => {
      this.emergencyContacts.splice(index, 1);
      this.cdr.detectChanges();
    });
  }

  private normalizePhotoUrl(photoUrl: string): string {
    const trimmed = photoUrl.trim();
    if (/^(https?:|data:|blob:)/i.test(trimmed)) {
      return trimmed;
    }
    const base = environment.apiUrl.replace(/\/api\/v1\/?$/, '');
    if (trimmed.startsWith('/')) {
      return `${base}${trimmed}`;
    }
    return `${base}/${trimmed}`;
  }
}
