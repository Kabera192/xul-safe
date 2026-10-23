import { ChangeDetectorRef, Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { ConductorService } from '../../services/conductor.service';
import { Conductor } from '../../models';
import { isValidEmail, isValidPhone } from '../../shared/validators';
import { catchError, finalize, of, timeout } from 'rxjs';

@Component({
  selector: 'app-conductor-create',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './conductor-create.html',
  styleUrl: './conductor-create.scss',
})
export class ConductorCreatePage {
  private conductorService = inject(ConductorService);
  private router = inject(Router);
  private cdr = inject(ChangeDetectorRef);

  // Account credentials
  email = '';
  password = '';
  // Profile
  fullName = '';
  gender = '';
  age = '';
  status: Conductor['status'] | '' = '';
  phone = '';
  licenceType = '';
  licenceExpiry = '';
  experience = '';
  photoPreview = '';
  isSaving = false;
  errorMessage = '';
  readonly genderOptions = [
    { label: 'Male', value: 'MALE' },
    { label: 'Female', value: 'FEMALE' },
    { label: 'Other', value: 'OTHER' },
  ] as const;
  readonly statusOptions = [
    { label: 'Active', value: 'ACTIVE' },
    { label: 'Inactive', value: 'INACTIVE' },
  ] as const;

  onPhotoSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (!input.files || input.files.length === 0) {
      return;
    }
    const file = input.files[0];
    const reader = new FileReader();
    reader.onload = () => {
      this.photoPreview = String(reader.result || '');
      this.cdr.detectChanges();
    };
    reader.readAsDataURL(file);
  }

  createConductor(): void {
    if (this.email && !isValidEmail(this.email)) {
      this.errorMessage = 'Please enter a valid email address.';
      this.cdr.detectChanges();
      return;
    }
    if (this.phone && !isValidPhone(this.phone)) {
      this.errorMessage = 'Please enter a valid phone number.';
      this.cdr.detectChanges();
      return;
    }

    this.isSaving = true;
    this.errorMessage = '';
    this.cdr.detectChanges();

    const payload: Conductor = {
      email: this.email || undefined,
      password: this.password || undefined,
      fullName: this.fullName,
      gender: this.gender || undefined,
      age: this.age ? Number(this.age) : undefined,
      status: (this.status || undefined) as Conductor['status'],
      phoneNumber: this.phone,
      licenceType: this.licenceType || undefined,
      licenceExpiry: this.licenceExpiry || undefined,
      experience: this.experience || undefined,
      photoUrl: this.photoPreview || undefined,
    };

    this.conductorService.create(payload).pipe(
      timeout(10000),
      catchError((error) => {
        console.error('Failed to create driver:', error);
        this.errorMessage = error?.message || 'Failed to create driver.';
        return of(null);
      }),
      finalize(() => {
        this.isSaving = false;
        this.cdr.detectChanges();
      })
    ).subscribe((created) => {
      if (created?.id != null) {
        this.router.navigate(['/drivers']);
      }
    });
  }
}
