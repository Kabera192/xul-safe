import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { ConductorService } from '../../services/conductor.service';
import { BusService } from '../../services/bus.service';
import { RouteService } from '../../services/route.service';
import { Bus, Conductor, Route } from '../../models';
import { environment } from '../../../environments/environment';
import { catchError, finalize, forkJoin, of, timeout } from 'rxjs';

@Component({
  selector: 'app-conductor-edit',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './conductor-edit.html',
  styleUrl: './conductor-edit.scss',
})
export class ConductorEditPage implements OnInit {
  private route = inject(ActivatedRoute);
  private router = inject(Router);
  private conductorService = inject(ConductorService);
  private busService = inject(BusService);
  private routeService = inject(RouteService);
  private cdr = inject(ChangeDetectorRef);

  conductorId = '';
  fullName = '';
  gender = '';
  email = '';
  age = '';
  status: Conductor['status'] | '' = '';
  driverId = '';
  phone = '';
  licenceNumber = '';
  licenceType = '';
  licenceExpiry = '';
  experience = '';
  assignedBus = '';
  assignedRoute = '';
  photoPreview = '';

  isLoading = false;
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

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (!id) {
      this.errorMessage = 'Invalid conductor ID.';
      return;
    }
    const numericId = Number(id);
    if (Number.isNaN(numericId)) {
      this.errorMessage = 'Invalid conductor ID.';
      return;
    }
    this.conductorId = id;
    this.loadConductor(numericId);
  }

  private loadConductor(conductorId: number): void {
    this.isLoading = true;
    this.errorMessage = '';
    const fallbackTimer = window.setTimeout(() => {
      if (this.isLoading) {
        this.isLoading = false;
        this.errorMessage = 'Failed to load conductor. Please try again.';
        this.cdr.detectChanges();
      }
    }, 5000);

    const conductorRequest = this.conductorService.getById(conductorId).pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load conductor:', error);
        return of(null as Conductor | null);
      })
    );

    const busesRequest = this.busService.getAll().pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load buses:', error);
        return of([] as Bus[]);
      })
    );

    const routesRequest = this.routeService.getAll().pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load routes:', error);
        return of([] as Route[]);
      })
    );

    forkJoin({
      conductor: conductorRequest,
      buses: busesRequest,
      routes: routesRequest
    }).pipe(
      finalize(() => {
        this.isLoading = false;
        window.clearTimeout(fallbackTimer);
        this.cdr.detectChanges();
      })
    ).subscribe(({ conductor, buses, routes }) => {
      if (!conductor) {
        this.errorMessage = 'Failed to load conductor.';
        return;
      }
      const assignedBus = buses.find((bus) => bus.conductorId === conductor.id);
      const assignedRoute = assignedBus?.routeId != null
        ? routes.find((route) => route.id === assignedBus.routeId)
        : undefined;

      this.fullName = conductor.fullName ?? '';
      this.gender = conductor.gender ?? '';
      this.email = conductor.email ?? '';
      this.age = conductor.age != null ? String(conductor.age) : '';
      this.status = conductor.status ?? '';
      this.driverId = conductor.driverId ?? (conductor.id != null ? `#DVR-${String(conductor.id).padStart(6, '0')}` : '');
      this.phone = conductor.phoneNumber ?? '';
      this.licenceNumber = conductor.licenceNumber ?? '';
      this.licenceType = conductor.licenceType ?? '';
      this.licenceExpiry = conductor.licenceExpiry ?? '';
      this.experience = conductor.experience ?? '';
      this.assignedBus = assignedBus?.plateNumber ?? '';
      this.assignedRoute = assignedRoute?.name ?? '';
      this.photoPreview = this.normalizePhotoUrl(conductor.photoUrl);
      this.cdr.detectChanges();
    });
  }

  onPhotoSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (!input.files || input.files.length === 0) {
      return;
    }
    const file = input.files[0];
    const reader = new FileReader();
    reader.onload = () => {
      this.photoPreview = String(reader.result || '');
    };
    reader.readAsDataURL(file);
  }

  saveChanges(): void {
    if (!this.conductorId) {
      return;
    }
    this.isSaving = true;
    this.errorMessage = '';
    this.cdr.detectChanges();

    const payload: Partial<Conductor> = {
      fullName: this.fullName,
      gender: this.gender || undefined,
      email: this.email || undefined,
      age: this.age ? Number(this.age) : undefined,
      status: (this.status || undefined) as Conductor['status'],
      driverId: this.driverId || undefined,
      phoneNumber: this.phone,
      licenceNumber: this.licenceNumber || undefined,
      licenceType: this.licenceType || undefined,
      licenceExpiry: this.licenceExpiry || undefined,
      experience: this.experience || undefined,
      photoUrl: this.photoPreview || undefined,
    };

    this.conductorService.update(Number(this.conductorId), payload).pipe(
      timeout(10000),
      finalize(() => {
        this.isSaving = false;
        this.cdr.detectChanges();
      })
    ).subscribe({
      next: () => {
        this.router.navigate(['/drivers']);
      },
      error: (error) => {
        console.error('Failed to update driver:', error);
        this.errorMessage = error?.message || 'Failed to update driver.';
        this.cdr.detectChanges();
      }
    });
  }

  private normalizePhotoUrl(photoUrl?: string | null): string {
    if (!photoUrl) {
      return '';
    }
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
