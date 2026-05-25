import { Component, OnInit, inject, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { BusStopService } from '../../services/bus-stop.service';
import { RouteService } from '../../services/route.service';
import { BusStop, Route } from '../../models';
import { catchError, of, finalize, timeout } from 'rxjs';

interface StopViewModel {
  id: string;
  name: string;
  location: string;
  order?: number;
}

@Component({
  selector: 'app-routes-stops',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './routes-stops.html',
  styleUrl: './routes-stops.scss',
})
export class RoutesStops implements OnInit {
  private busStopService = inject(BusStopService);
  private routeService = inject(RouteService);
  private cdr = inject(ChangeDetectorRef);

  searchTerm = '';
  showRouteModal = false;
  routeName = '';
  routeStart = '';
  routeEnd = '';
  routeDescription = '';
  isLoading = false;
  isLoadingStops = false;
  isSaving = false;
  errorMessage = '';
  successMessage = '';
  selectedRoute: Route | null = null;
  editingRoute: Route | null = null; // null = create mode, Route = edit mode

  routes: Route[] = [];
  stops: StopViewModel[] = [];

  ngOnInit(): void {
    this.loadRoutes();
  }

  loadRoutes(): void {
    this.isLoading = true;
    this.errorMessage = '';

    this.routeService.getAll().pipe(
      timeout(10000), // 10 second timeout
      catchError((error) => {
        console.error('Failed to load routes:', error);
        this.errorMessage = error.name === 'TimeoutError'
          ? 'Request timed out. Please try again.'
          : 'Failed to load routes. Please try again.';
        return of([]);
      }),
      finalize(() => {
        this.isLoading = false;
        this.cdr.detectChanges();
      })
    ).subscribe((routes) => {
      this.routes = routes;
      this.cdr.detectChanges();
    });
  }

  loadBusStopsForRoute(routeId: number): void {
    this.isLoadingStops = true;
    this.stops = [];

    this.busStopService.getByRoute(routeId).pipe(
      timeout(10000), // 10 second timeout
      catchError((error) => {
        console.error('Failed to load bus stops for route:', error);
        return of([]);
      }),
      finalize(() => {
        this.isLoadingStops = false;
        this.cdr.detectChanges();
      })
    ).subscribe((busStops) => {
      this.stops = busStops.map(stop => this.mapBusStopToViewModel(stop));
      this.cdr.detectChanges();
    });
  }

  private mapBusStopToViewModel(busStop: BusStop): StopViewModel {
    return {
      id: busStop.id || '',
      name: busStop.name,
      location: busStop.address || `${busStop.latitude}, ${busStop.longitude}`,
      order: busStop.stopOrder || busStop.order // Backend uses stopOrder
    };
  }

  get filteredRoutes(): Route[] {
    if (!this.searchTerm.trim()) {
      return this.routes;
    }
    const term = this.searchTerm.toLowerCase();
    return this.routes.filter(route =>
      route.name.toLowerCase().includes(term) ||
      route.startLocation?.toLowerCase().includes(term) ||
      route.endLocation?.toLowerCase().includes(term)
    );
  }

  openRouteModal(): void {
    this.editingRoute = null;
    this.showRouteModal = true;
    this.resetRouteForm();
  }

  openEditModal(route: Route, event: Event): void {
    event.stopPropagation();
    this.editingRoute = route;
    this.routeName = route.name;
    this.routeStart = route.startLocation || '';
    this.routeEnd = route.endLocation || '';
    this.routeDescription = route.description || '';
    this.showRouteModal = true;
  }

  closeRouteModal(): void {
    this.showRouteModal = false;
    this.editingRoute = null;
    this.resetRouteForm();
  }

  private resetRouteForm(): void {
    this.routeName = '';
    this.routeStart = '';
    this.routeEnd = '';
    this.routeDescription = '';
  }

  get isEditMode(): boolean {
    return this.editingRoute !== null;
  }

  get modalTitle(): string {
    return this.isEditMode ? 'Edit route' : 'Create a route';
  }

  get submitButtonText(): string {
    if (this.isSaving) {
      return this.isEditMode ? 'Saving...' : 'Creating...';
    }
    return this.isEditMode ? 'Save changes' : 'Create route';
  }

  saveRoute(): void {
    if (!this.routeName.trim()) {
      return;
    }

    this.isSaving = true;
    this.errorMessage = '';
    this.successMessage = '';

    const routeData: Route = {
      name: this.routeName.trim(),
      startLocation: this.routeStart.trim(),
      endLocation: this.routeEnd.trim(),
      description: this.routeDescription.trim()
    };

    const request$ = this.isEditMode
      ? this.routeService.update(this.editingRoute!.id!, routeData)
      : this.routeService.create(routeData);

    request$.pipe(
      finalize(() => {
        this.isSaving = false;
        this.cdr.detectChanges();
      })
    ).subscribe({
      next: () => {
        this.successMessage = this.isEditMode
          ? 'Route updated successfully!'
          : 'Route created successfully!';
        this.showRouteModal = false;
        this.editingRoute = null;
        this.resetRouteForm();
        this.loadRoutes(); // Refresh the list from API
        this.cdr.detectChanges();

        // Auto-hide success message after 3 seconds
        setTimeout(() => {
          this.successMessage = '';
          this.cdr.detectChanges();
        }, 3000);
      },
      error: (error) => {
        console.error('Failed to save route:', error);
        this.errorMessage = this.isEditMode
          ? 'Failed to update route. Please try again.'
          : 'Failed to create route. Please try again.';
        this.cdr.detectChanges();
      }
    });
  }

  deleteRoute(route: Route, event: Event): void {
    event.stopPropagation();
    if (!route.id) return;

    if (confirm(`Are you sure you want to delete the route "${route.name}"?`)) {
      this.errorMessage = '';
      this.successMessage = '';

      this.routeService.delete(route.id).subscribe({
        next: () => {
          this.routes = this.routes.filter(r => r.id !== route.id);
          if (this.selectedRoute?.id === route.id) {
            this.selectedRoute = null;
            this.stops = [];
          }
          this.successMessage = 'Route deleted successfully!';
          this.cdr.detectChanges();

          setTimeout(() => {
            this.successMessage = '';
            this.cdr.detectChanges();
          }, 3000);
        },
        error: (error) => {
          console.error('Failed to delete route:', error);
          this.errorMessage = 'Failed to delete route. Please try again.';
          this.cdr.detectChanges();
        }
      });
    }
  }

  selectRoute(route: Route): void {
    this.selectedRoute = route;
    if (route.id) {
      this.loadBusStopsForRoute(route.id);
    }
  }
}
