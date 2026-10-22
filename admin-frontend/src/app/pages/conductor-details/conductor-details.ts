import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ConductorService } from '../../services/conductor.service';
import { BusService } from '../../services/bus.service';
import { RouteService } from '../../services/route.service';
import { Bus, Conductor, Route } from '../../models';
import { environment } from '../../../environments/environment';
import { catchError, finalize, forkJoin, of, timeout } from 'rxjs';

type ConductorDetails = {
  id: string;
  name: string;
  gender: string;
  age: string;
  phone: string;
  email: string;
  photoUrl?: string;
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
  private routeService = inject(RouteService);
  private cdr = inject(ChangeDetectorRef);

  conductor: ConductorDetails = {
    id: '',
    name: 'N/A',
    gender: 'N/A',
    age: 'N/A',
    phone: 'N/A',
    email: 'N/A',
    photoUrl: undefined,
    licenceType: 'N/A',
    licenceExpiry: 'N/A',
    experience: 'N/A',
    assignedBus: 'Unassigned',
    assignedRoute: 'N/A',
  };

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

    const routeRequest = this.routeService.getAll().pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load routes:', error);
        return of([] as Route[]);
      })
    );

    forkJoin({
      conductor: conductorRequest,
      buses: busRequest,
      routes: routeRequest
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
      this.conductor = {
        id: String(conductor.id ?? conductorId),
        name: conductor.fullName ?? 'N/A',
        gender: conductor.gender ?? 'N/A',
        age: conductor.age != null ? String(conductor.age) : 'N/A',
        phone: conductor.phoneNumber ?? 'N/A',
        email: conductor.email ?? 'N/A',
        photoUrl: this.normalizePhotoUrl(conductor.photoUrl),
        licenceType: conductor.licenceType ?? 'N/A',
        licenceExpiry: conductor.licenceExpiry ?? 'N/A',
        experience: conductor.experience ?? 'N/A',
        assignedBus: assignedBus?.plateNumber ?? 'Unassigned',
        assignedRoute: assignedRoute?.name ?? 'N/A',
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
