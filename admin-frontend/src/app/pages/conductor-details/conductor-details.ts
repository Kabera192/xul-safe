import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ConductorService } from '../../services/conductor.service';
import { BusService } from '../../services/bus.service';
import { Bus, Conductor } from '../../models';
import { environment } from '../../../environments/environment';
import { catchError, finalize, forkJoin, of, timeout } from 'rxjs';

type ConductorDetails = {
  id: string;
  name: string;
  gender: string;
  driverId: string;
  age: string;
  phone: string;
  email: string;
  photoUrl?: string;
  licenceNumber: string;
  licenceType: string;
  licenceExpiry: string;
  experience: string;
  assignedBus: string;
  assignedRoute: string;
};

@Component({
  selector: 'app-conductor-details',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './conductor-details.html',
  styleUrl: './conductor-details.scss',
})
export class ConductorDetailsPage implements OnInit {
  private conductorService = inject(ConductorService);
  private busService = inject(BusService);
  private cdr = inject(ChangeDetectorRef);

  conductor: ConductorDetails = {
    id: '',
    name: 'N/A',
    gender: 'N/A',
    driverId: 'N/A',
    age: 'N/A',
    phone: 'N/A',
    email: 'N/A',
    photoUrl: undefined,
    licenceNumber: 'N/A',
    licenceType: 'N/A',
    licenceExpiry: 'N/A',
    experience: 'N/A',
    assignedBus: 'Unassigned',
    assignedRoute: 'N/A',
  };

  performance = [
    { label: 'Trips Completed', value: '124' },
    { label: 'Missed Shifts', value: '4' },
    { label: 'Incidents', value: '3', danger: true },
    { label: 'Leaves', value: '5' },
  ];

  isLoading = false;
  errorMessage = '';
  private route = inject(ActivatedRoute);

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (!id) {
      return;
    }
    const numericId = Number(id);
    if (Number.isNaN(numericId)) {
      this.errorMessage = 'Invalid conductor ID.';
      return;
    }
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

    const busRequest = this.busService.getAll().pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load buses:', error);
        return of([] as Bus[]);
      })
    );

    forkJoin({
      conductor: conductorRequest,
      buses: busRequest
    }).pipe(
      finalize(() => {
        this.isLoading = false;
        window.clearTimeout(fallbackTimer);
        this.cdr.detectChanges();
      })
    ).subscribe(({ conductor, buses }) => {
      if (!conductor) {
        this.errorMessage = 'Failed to load conductor.';
        return;
      }
      const assignedBus = buses.find((bus) => bus.conductorId === conductor.id);
      this.conductor = {
        id: String(conductor.id ?? conductorId),
        name: conductor.fullName ?? 'N/A',
        gender: conductor.gender ?? 'N/A',
        driverId: conductor.driverId ?? (conductor.id != null ? `#DVR-${String(conductor.id).padStart(6, '0')}` : 'N/A'),
        age: conductor.age != null ? String(conductor.age) : 'N/A',
        phone: conductor.phoneNumber ?? 'N/A',
        email: conductor.email ?? 'N/A',
        photoUrl: this.normalizePhotoUrl(conductor.photoUrl),
        licenceNumber: conductor.licenceNumber ?? 'N/A',
        licenceType: conductor.licenceType ?? 'N/A',
        licenceExpiry: conductor.licenceExpiry ?? 'N/A',
        experience: conductor.experience ?? 'N/A',
        assignedBus: assignedBus?.plateNumber ?? 'Unassigned',
        assignedRoute: 'N/A',
      };
      this.cdr.detectChanges();
    });
  }

  private normalizePhotoUrl(photoUrl?: string | null): string | undefined {
    if (!photoUrl) {
      return undefined;
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
