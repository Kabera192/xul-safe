import { ChangeDetectorRef, Component, OnDestroy, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { Router } from '@angular/router';
import { BusService } from '../../services/bus.service';
import { ConductorService } from '../../services/conductor.service';
import { RouteService } from '../../services/route.service';
import { Bus, Conductor, Route } from '../../models';
import { Subscription, catchError, finalize, of, timeout } from 'rxjs';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-bus-edit',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './bus-edit.html',
  styleUrl: './bus-edit.scss',
})
export class BusEditPage implements OnInit, OnDestroy {
  private busService = inject(BusService);
  private conductorService = inject(ConductorService);
  private routeService = inject(RouteService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  private cdr = inject(ChangeDetectorRef);
  private routeSub?: Subscription;

  busId?: number;
  plateNumber = '';
  model = '';
  capacity = '';
  status = 'ACTIVE';
  selectedRouteId = '';
  selectedConductorId = '';
  conductors: Conductor[] = [];
  routes: Route[] = [];
  photoPreview = '';
  isSaving = false;
  isLoading = false;
  errorMessage = '';
  noticeMessage = '';
  private conductorsLoaded = false;
  private routesLoaded = false;
  private busApplied = false;

  ngOnInit(): void {
    this.loadConductors();
    this.loadRoutes();
    this.routeSub = this.route.paramMap.subscribe((params) => {
      const idParam = params.get('id');
      this.resetFormState();
      if (!idParam) {
        return;
      }
      const numericId = Number(idParam);
      if (Number.isNaN(numericId)) {
        this.errorMessage = 'Invalid bus ID.';
        return;
      }
      this.busId = numericId;
      this.loadBusById(this.busId);
    });
  }

  ngOnDestroy(): void {
    this.routeSub?.unsubscribe();
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
      this.conductorsLoaded = true;
      this.pruneStaleReferences();
      this.cdr.detectChanges();
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
      this.routesLoaded = true;
      this.pruneStaleReferences();
      this.cdr.detectChanges();
    });
  }

  /**
   * A bus can reference a conductor/route that was since deleted elsewhere.
   * The <select> then shows nothing selected (no matching <option>), but the
   * stale ID was still sitting in the bound field and would otherwise be
   * submitted as-is, producing a confusing "not found" error for a field
   * that looks blank. Clear it so a visibly blank field behaves as blank.
   *
   * Conductors, routes, and the bus itself load via three independent async
   * calls with no guaranteed order — wait until all three have actually
   * landed before checking, otherwise a list that just hasn't arrived yet
   * looks identical to "this ID doesn't exist" and gets wrongly cleared.
   */
  private pruneStaleReferences(): void {
    if (!this.conductorsLoaded || !this.routesLoaded || !this.busApplied) {
      return;
    }

    const staleConductor = this.selectedConductorId &&
      !this.conductors.some((c) => String(c.id) === this.selectedConductorId);
    const staleRoute = this.selectedRouteId &&
      !this.routes.some((r) => String(r.id) === this.selectedRouteId);

    if (staleConductor) {
      this.selectedConductorId = '';
    }
    if (staleRoute) {
      this.selectedRouteId = '';
    }
    if (staleConductor || staleRoute) {
      const fields = [staleConductor ? 'conductor' : null, staleRoute ? 'route' : null]
        .filter(Boolean)
        .join(' and ');
      this.noticeMessage = `The previously assigned ${fields} is no longer available. Please select one if needed.`;
    }
  }

  private resetFormState(): void {
    this.busId = undefined;
    this.plateNumber = '';
    this.model = '';
    this.capacity = '';
    this.status = 'ACTIVE';
    this.selectedRouteId = '';
    this.selectedConductorId = '';
    this.errorMessage = '';
    this.noticeMessage = '';
    this.busApplied = false;
  }

  private loadBusById(busId: number): void {
    this.isLoading = true;
    this.errorMessage = '';

    this.busService.getById(busId).pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load bus:', error);
        this.errorMessage = error?.message || 'Failed to load bus.';
        return of(null as Bus | null);
      }),
      finalize(() => {
        this.isLoading = false;
        this.cdr.detectChanges();
      })
    ).subscribe((bus) => {
      console.log('Bus data received:', bus);
      if (!bus) {
        this.errorMessage = this.errorMessage || 'Bus not found.';
        return;
      }
      this.applyBus(bus);
      this.busApplied = true;
      this.pruneStaleReferences();
      this.cdr.detectChanges();
    });
  }

  private applyBus(bus: Bus): void {
    this.plateNumber = bus.plateNumber ?? '';
    this.model = bus.model ?? '';
    this.capacity = bus.capacity != null ? String(bus.capacity) : '';
    this.status = (bus.status ?? 'ACTIVE') as string;
    this.selectedConductorId = bus.conductorId != null ? String(bus.conductorId) : '';
    this.selectedRouteId = bus.routeId != null ? String(bus.routeId) : '';
    this.photoPreview = this.normalizePhotoUrl(bus.photoUrl);
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
    if (!this.busId) {
      this.errorMessage = 'Missing bus ID. Please reload the page.';
      return;
    }
    this.isSaving = true;
    this.errorMessage = '';
    this.busService.update(Number(this.busId), {
      plateNumber: this.plateNumber,
      model: this.model || undefined,
      capacity: this.capacity ? Number(this.capacity) : undefined,
      status: this.status as Bus['status'],
      conductorId: this.selectedConductorId ? Number(this.selectedConductorId) : undefined,
      routeId: this.selectedRouteId ? Number(this.selectedRouteId) : undefined,
      photoUrl: this.photoPreview || undefined
    }).pipe(
      timeout(5000),
      finalize(() => {
        this.isSaving = false;
        this.cdr.detectChanges();
      })
    ).subscribe({
      next: () => {
        this.router.navigate(['/school-buses']);
      },
      error: (error) => {
        this.errorMessage = error?.message || 'Failed to update bus.';
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
