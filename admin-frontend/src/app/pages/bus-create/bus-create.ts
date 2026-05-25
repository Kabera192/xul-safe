import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { BusService } from '../../services/bus.service';
import { ConductorService } from '../../services/conductor.service';
import { RouteService } from '../../services/route.service';
import { Bus, Conductor, Route } from '../../models';
import { Router } from '@angular/router';
import { catchError, finalize, of, timeout } from 'rxjs';

@Component({
  selector: 'app-bus-create',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './bus-create.html',
  styleUrl: './bus-create.scss',
})
export class BusCreatePage implements OnInit {
  private busService = inject(BusService);
  private conductorService = inject(ConductorService);
  private routeService = inject(RouteService);
  private router = inject(Router);

  plateNumber = '';
  model = '';
  capacity = '';
  status = 'ACTIVE';
  deviceId = '';
  selectedRouteId = '';
  selectedConductorId = '';
  conductors: Conductor[] = [];
  routes: Route[] = [];
  photoPreview = '';
  isSaving = false;
  errorMessage = '';

  ngOnInit(): void {
    this.loadConductors();
    this.loadRoutes();
  }

  loadConductors(): void {
    this.conductorService.getAll().pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load conductors:', error);
        return of([] as Conductor[]);
      })
    ).subscribe((conductors) => {
      this.conductors = conductors;
    });
  }

  loadRoutes(): void {
    this.routeService.getAll().pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load routes:', error);
        return of([] as Route[]);
      })
    ).subscribe((routes) => {
      this.routes = routes;
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

  createBus(): void {
    this.isSaving = true;
    this.errorMessage = '';
    const payload: Bus = {
      plateNumber: this.plateNumber,
      model: this.model || undefined,
      capacity: this.capacity ? Number(this.capacity) : undefined,
      status: this.status as Bus['status'],
      conductorId: this.selectedConductorId ? Number(this.selectedConductorId) : undefined,
      deviceId: this.deviceId || undefined,
      routeId: this.selectedRouteId ? Number(this.selectedRouteId) : undefined,
      photoUrl: this.photoPreview || undefined
    };
    this.busService.create(payload).pipe(
      timeout(5000),
      catchError((error) => {
        this.errorMessage = error?.message || 'Failed to create bus.';
        return of(null);
      }),
      finalize(() => {
        this.isSaving = false;
      })
    ).subscribe((bus) => {
      if (bus?.id) {
        this.router.navigate(['/school-buses']);
      }
    });
  }
}
