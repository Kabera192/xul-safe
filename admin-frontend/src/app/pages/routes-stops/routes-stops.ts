import { Component, OnInit, OnDestroy, inject, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { BusStopService } from '../../services/bus-stop.service';
import { RouteService } from '../../services/route.service';
import { BusService } from '../../services/bus.service';
import { StudentService } from '../../services/student.service';
import { Bus, BusStop, Child, ChildDetail, Route } from '../../models';
import { catchError, of, finalize, timeout, forkJoin, Subject, debounceTime, distinctUntilChanged, switchMap } from 'rxjs';
import { applySort, initialSortState, SortState, sortIndicator, toggleSort } from '../../shared/table-sort';
import { MapPickerComponent } from '../../shared/map-picker/map-picker.component';
import { GeocodingService, PlaceSuggestion } from '../../shared/geocoding.service';

interface StopViewModel {
  id: string;
  name: string;
  location: string;
  order?: number;
}

type StopSortColumn = 'name' | 'location';

@Component({
  selector: 'app-routes-stops',
  standalone: true,
  imports: [CommonModule, FormsModule, MapPickerComponent],
  templateUrl: './routes-stops.html',
  styleUrl: './routes-stops.scss',
})
export class RoutesStops implements OnInit, OnDestroy {
  private busStopService = inject(BusStopService);
  private routeService = inject(RouteService);
  private busService = inject(BusService);
  private studentService = inject(StudentService);
  private geocodingService = inject(GeocodingService);
  private cdr = inject(ChangeDetectorRef);

  searchTerm = '';
  showRouteModal = false;
  routeName = '';
  routeStart = '';
  routeEnd = '';
  routeDescription = '';
  routeStartSuggestions: PlaceSuggestion[] = [];
  routeEndSuggestions: PlaceSuggestion[] = [];
  isSearchingRouteStart = false;
  isSearchingRouteEnd = false;
  private routeStartSearch$ = new Subject<string>();
  private routeEndSearch$ = new Subject<string>();
  isLoading = false;
  isLoadingStops = false;
  isSaving = false;
  errorMessage = '';
  successMessage = '';
  selectedRoute: Route | null = null;
  editingRoute: Route | null = null;

  routes: Route[] = [];
  stops: StopViewModel[] = [];
  stopSortState: SortState<StopSortColumn> = initialSortState();

  // Bus stop modal state
  showStopModal = false;
  editingStop: StopViewModel | null = null;
  stopName = '';
  stopAddress = '';
  stopLatitude: number | null = null;
  stopLongitude: number | null = null;
  stopOrder: number | null = null;
  isSavingStop = false;
  stopSearchTerm = '';
  stopSuggestions: PlaceSuggestion[] = [];
  isSearchingStop = false;
  isCapturingLocation = false;
  locateError = '';
  private stopSearch$ = new Subject<string>();

  // Assign students modal state
  showAssignStudentsModal = false;
  assigningStop: StopViewModel | null = null;
  isLoadingAssignCandidates = false;
  assignCandidates: ChildDetail[] = [];
  selectedChildIds = new Set<string>();
  savingChildIds = new Set<string>();
  routeBus: Bus | null = null;

  ngOnInit(): void {
    this.loadRoutes();
    this.setupLocationSearch();
  }

  ngOnDestroy(): void {
    this.routeStartSearch$.complete();
    this.routeEndSearch$.complete();
    this.stopSearch$.complete();
    this.clearLocateTimeout();
  }

  private setupLocationSearch(): void {
    this.routeStartSearch$.pipe(
      debounceTime(250),
      distinctUntilChanged(),
      switchMap((query) => this.geocodingService.searchPlaces(query))
    ).subscribe((suggestions) => {
      this.routeStartSuggestions = suggestions;
      this.isSearchingRouteStart = false;
      this.cdr.detectChanges();
    });

    this.routeEndSearch$.pipe(
      debounceTime(250),
      distinctUntilChanged(),
      switchMap((query) => this.geocodingService.searchPlaces(query))
    ).subscribe((suggestions) => {
      this.routeEndSuggestions = suggestions;
      this.isSearchingRouteEnd = false;
      this.cdr.detectChanges();
    });

    this.stopSearch$.pipe(
      debounceTime(250),
      distinctUntilChanged(),
      switchMap((query) => this.geocodingService.searchPlaces(query))
    ).subscribe((suggestions) => {
      this.stopSuggestions = suggestions;
      this.isSearchingStop = false;
      this.cdr.detectChanges();
    });
  }

  onRouteStartQueryChange(value: string): void {
    const trimmed = value.trim();
    if (trimmed.length < 3) {
      this.routeStartSuggestions = [];
      this.isSearchingRouteStart = false;
      return;
    }
    this.isSearchingRouteStart = true;
    this.routeStartSearch$.next(trimmed);
  }

  onRouteEndQueryChange(value: string): void {
    const trimmed = value.trim();
    if (trimmed.length < 3) {
      this.routeEndSuggestions = [];
      this.isSearchingRouteEnd = false;
      return;
    }
    this.isSearchingRouteEnd = true;
    this.routeEndSearch$.next(trimmed);
  }

  selectRouteStartSuggestion(suggestion: PlaceSuggestion): void {
    this.routeStart = suggestion.name;
    this.routeStartSuggestions = [];
  }

  selectRouteEndSuggestion(suggestion: PlaceSuggestion): void {
    this.routeEnd = suggestion.name;
    this.routeEndSuggestions = [];
  }

  loadRoutes(): void {
    this.isLoading = true;
    this.errorMessage = '';

    this.routeService.getAll().pipe(
      timeout(10000),
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
    this.errorMessage = '';

    this.busStopService.getByRoute(routeId).pipe(
      timeout(10000),
      catchError((error) => {
        console.error('Failed to load bus stops for route:', error);
        this.errorMessage = error.name === 'TimeoutError'
          ? 'Could not load bus stops: request timed out.'
          : `Could not load bus stops: ${error.message || 'please try again.'}`;
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
      id: busStop.id?.toString() ?? '',
      name: busStop.name,
      location: busStop.address || `${busStop.latitude}, ${busStop.longitude}`,
      order: busStop.stopOrder ?? busStop.order
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

  // ── Route modal ────────────────────────────────────────────────────────────

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
    this.routeStartSuggestions = [];
    this.routeEndSuggestions = [];
    this.isSearchingRouteStart = false;
    this.isSearchingRouteEnd = false;
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
        this.loadRoutes();
        this.cdr.detectChanges();

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
    this.errorMessage = '';
    if (route.id) {
      this.loadBusStopsForRoute(route.id);
    }
  }

  // ── Bus stop modal ─────────────────────────────────────────────────────────

  openAddStopModal(): void {
    this.editingStop = null;
    this.resetStopForm();
    this.showStopModal = true;
  }

  openEditStopModal(stop: StopViewModel, event: Event): void {
    event.stopPropagation();
    this.editingStop = stop;
    this.stopName = stop.name;
    this.stopAddress = stop.location;
    this.stopLatitude = null;
    this.stopLongitude = null;
    this.stopOrder = stop.order ?? null;
    this.showStopModal = true;

    // The stops list view model doesn't carry coordinates — fetch the full
    // record so the admin can see (and selectively edit) the current lat/long.
    this.busStopService.getById(stop.id).pipe(
      catchError(() => of(null))
    ).subscribe((fullStop) => {
      if (!fullStop || this.editingStop?.id !== stop.id) return;
      this.stopAddress = fullStop.address || stop.location;
      this.stopLatitude = fullStop.latitude ?? null;
      this.stopLongitude = fullStop.longitude ?? null;
      this.cdr.detectChanges();
    });
  }

  closeStopModal(): void {
    this.showStopModal = false;
    this.editingStop = null;
    this.resetStopForm();
  }

  private resetStopForm(): void {
    this.clearLocateTimeout();
    this.stopName = '';
    this.stopAddress = '';
    this.stopLatitude = null;
    this.stopLongitude = null;
    this.stopOrder = null;
    this.stopSearchTerm = '';
    this.stopSuggestions = [];
    this.isSearchingStop = false;
    this.isCapturingLocation = false;
    this.locateError = '';
  }

  onStopSearchQueryChange(value: string): void {
    const trimmed = value.trim();
    if (trimmed.length < 3) {
      this.stopSuggestions = [];
      this.isSearchingStop = false;
      return;
    }
    this.isSearchingStop = true;
    this.stopSearch$.next(trimmed);
  }

  selectStopSuggestion(suggestion: PlaceSuggestion): void {
    this.stopSearchTerm = suggestion.name;
    this.stopAddress = suggestion.name;
    this.stopLatitude = suggestion.lat;
    this.stopLongitude = suggestion.lng;
    this.stopSuggestions = [];
  }

  private locateTimeoutId: ReturnType<typeof setTimeout> | null = null;

  useMyLocationForStop(): void {
    if (!navigator.geolocation) {
      this.locateError = 'Location is not supported by this browser.';
      return;
    }

    this.isCapturingLocation = true;
    this.locateError = '';

    // Some browsers (notably Chrome on Windows with the OS-level Location
    // setting off) can hang indefinitely and never call either callback,
    // ignoring the `timeout` option below. This fallback guarantees the
    // button always recovers instead of being stuck on "Capturing…".
    this.locateTimeoutId = setTimeout(() => {
      this.locateTimeoutId = null;
      this.isCapturingLocation = false;
      this.locateError = 'Could not get your location. Check that location access is allowed for this browser and your device, then try again.';
      this.cdr.detectChanges();
    }, 12000);

    navigator.geolocation.getCurrentPosition(
      (position) => {
        this.clearLocateTimeout();
        this.isCapturingLocation = false;
        this.onStopPositionPicked({
          lat: position.coords.latitude,
          lng: position.coords.longitude,
        });
        this.cdr.detectChanges();
      },
      () => {
        this.clearLocateTimeout();
        this.isCapturingLocation = false;
        this.locateError = 'Could not capture current location.';
        this.cdr.detectChanges();
      },
      { enableHighAccuracy: true, timeout: 10000 }
    );
  }

  private clearLocateTimeout(): void {
    if (this.locateTimeoutId !== null) {
      clearTimeout(this.locateTimeoutId);
      this.locateTimeoutId = null;
    }
  }

  onStopPositionPicked(position: { lat: number; lng: number }): void {
    this.stopLatitude = position.lat;
    this.stopLongitude = position.lng;

    this.geocodingService.reverseGeocode(position.lat, position.lng).subscribe((address) => {
      if (address) {
        this.stopAddress = address;
        this.cdr.detectChanges();
      }
    });
  }

  get isStopEditMode(): boolean {
    return this.editingStop !== null;
  }

  get stopModalTitle(): string {
    return this.isStopEditMode ? 'Edit bus stop' : 'Add bus stop';
  }

  get stopSubmitButtonText(): string {
    if (this.isSavingStop) {
      return this.isStopEditMode ? 'Saving...' : 'Adding...';
    }
    return this.isStopEditMode ? 'Save changes' : 'Add stop';
  }

  get stopFormValid(): boolean {
    // Latitude/longitude are optional — only the stop name is required.
    return !!this.stopName.trim();
  }

  get sortedStops(): StopViewModel[] {
    return applySort(this.stops, this.stopSortState, (row, column) => row[column]);
  }

  sortStops(column: StopSortColumn): void {
    this.stopSortState = toggleSort(this.stopSortState, column);
  }

  stopSortArrow(column: StopSortColumn): string {
    return sortIndicator(this.stopSortState, column);
  }

  saveStop(): void {
    if (!this.stopFormValid || !this.selectedRoute?.id) return;

    this.isSavingStop = true;
    this.errorMessage = '';

    if (this.isStopEditMode && this.editingStop) {
      const updatePayload: Partial<BusStop> = {
        name: this.stopName.trim(),
        address: this.stopAddress.trim() || undefined,
        ...(this.stopLatitude !== null && { latitude: this.stopLatitude }),
        ...(this.stopLongitude !== null && { longitude: this.stopLongitude }),
        ...(this.stopOrder !== null && { stopOrder: this.stopOrder }),
      };

      this.busStopService.update(this.editingStop.id, updatePayload).pipe(
        finalize(() => {
          this.isSavingStop = false;
          this.cdr.detectChanges();
        })
      ).subscribe({
        next: () => {
          this.successMessage = 'Bus stop updated successfully!';
          this.closeStopModal();
          this.loadBusStopsForRoute(this.selectedRoute!.id!);
          this.cdr.detectChanges();
          setTimeout(() => { this.successMessage = ''; this.cdr.detectChanges(); }, 3000);
        },
        error: (error) => {
          console.error('Failed to update bus stop:', error);
          this.errorMessage = 'Failed to update bus stop. Please try again.';
          this.cdr.detectChanges();
        }
      });
    } else {
      const createPayload: Partial<BusStop> = {
        name: this.stopName.trim(),
        address: this.stopAddress.trim() || undefined,
        routeId: this.selectedRoute.id,
        ...(this.stopLatitude !== null && { latitude: this.stopLatitude }),
        ...(this.stopLongitude !== null && { longitude: this.stopLongitude }),
        ...(this.stopOrder !== null && { stopOrder: this.stopOrder }),
      };

      this.busStopService.create(createPayload).pipe(
        finalize(() => {
          this.isSavingStop = false;
          this.cdr.detectChanges();
        })
      ).subscribe({
        next: () => {
          this.successMessage = 'Bus stop added successfully!';
          this.closeStopModal();
          this.loadBusStopsForRoute(this.selectedRoute!.id!);
          this.cdr.detectChanges();
          setTimeout(() => { this.successMessage = ''; this.cdr.detectChanges(); }, 3000);
        },
        error: (error) => {
          console.error('Failed to add bus stop:', error);
          this.errorMessage = 'Failed to add bus stop. Please try again.';
          this.cdr.detectChanges();
        }
      });
    }
  }

  // ── Assign students modal ──────────────────────────────────────────────────

  openAssignStudentsModal(stop: StopViewModel, event: Event): void {
    event.stopPropagation();
    this.assigningStop = stop;
    this.selectedChildIds.clear();
    this.savingChildIds.clear();
    this.routeBus = null;
    this.assignCandidates = [];
    this.showAssignStudentsModal = true;
    this.loadAssignCandidates();
  }

  closeAssignStudentsModal(): void {
    this.showAssignStudentsModal = false;
    this.assigningStop = null;
    this.assignCandidates = [];
    this.selectedChildIds.clear();
    this.savingChildIds.clear();
    this.routeBus = null;
  }

  private loadAssignCandidates(): void {
    const routeId = this.selectedRoute?.id;
    const stopId = this.assigningStop?.id;
    if (!routeId) return;

    this.isLoadingAssignCandidates = true;
    this.errorMessage = '';

    forkJoin({
      buses: this.busService.getAll().pipe(catchError(() => of([] as Bus[]))),
      children: this.studentService.getAllWithDetails().pipe(catchError(() => of([] as ChildDetail[]))),
    }).pipe(
      timeout(10000),
      finalize(() => {
        this.isLoadingAssignCandidates = false;
        this.cdr.detectChanges();
      })
    ).subscribe(({ buses, children }) => {
      // A route's bus is whichever bus has routeId pointing back at this route —
      // there's no direct route → bus reference, only bus → route.
      this.routeBus = buses.find(b => b.routeId === routeId) ?? null;
      this.assignCandidates = this.routeBus
        ? children.filter(c => c.busId === this.routeBus!.id)
        : [];
      // Pre-select whoever is already on this stop, so their checkbox reflects
      // the real current state instead of starting empty.
      this.selectedChildIds = new Set(
        this.assignCandidates
          .filter(c => c.id && c.busStopId === stopId)
          .map(c => c.id!)
      );
      this.cdr.detectChanges();
    });
  }

  isAlreadyOnThisStop(child: ChildDetail): boolean {
    return !!this.assigningStop && child.busStopId === this.assigningStop.id;
  }

  isReassign(child: ChildDetail): boolean {
    return !this.selectedChildIds.has(child.id ?? '') &&
      !!child.busStopId && !this.isAlreadyOnThisStop(child);
  }

  /**
   * Checking/unchecking a student saves immediately — assigning them to this
   * stop, or clearing their stop if unchecked — rather than batching changes
   * behind a separate save button.
   */
  toggleChildSelection(child: ChildDetail): void {
    const childId = child.id;
    if (!childId || !this.assigningStop || this.savingChildIds.has(childId)) return;

    const stopId = this.assigningStop.id;
    const willBeSelected = !this.selectedChildIds.has(childId);
    const previousBusStopId = child.busStopId;

    // Optimistic UI update
    if (willBeSelected) this.selectedChildIds.add(childId);
    else this.selectedChildIds.delete(childId);
    this.savingChildIds.add(childId);
    this.errorMessage = '';
    this.cdr.detectChanges();

    // The backend's updateChild always overwrites busId/busStopId from
    // whatever is in the request body (no null-check, unlike the other
    // fields), so we must resend the child's current busId here —
    // otherwise a stop-only payload would silently wipe out their bus
    // assignment.
    const payload = {
      busId: child.busId,
      busStopId: willBeSelected ? stopId : null,
    };

    this.studentService.update(childId, payload as unknown as Partial<Child>).pipe(
      finalize(() => {
        this.savingChildIds.delete(childId);
        this.cdr.detectChanges();
      })
    ).subscribe({
      next: () => {
        child.busStopId = willBeSelected ? stopId : undefined;
        this.cdr.detectChanges();
      },
      error: (error) => {
        console.error('Failed to update student stop assignment:', error);
        // Revert the optimistic change
        if (willBeSelected) this.selectedChildIds.delete(childId);
        else this.selectedChildIds.add(childId);
        child.busStopId = previousBusStopId;
        this.errorMessage = `Failed to update ${child.fullName}. Please try again.`;
        this.cdr.detectChanges();
      }
    });
  }

  deleteStop(stop: StopViewModel, event: Event): void {
    event.stopPropagation();
    if (!stop.id) return;

    if (confirm(`Are you sure you want to remove the stop "${stop.name}" from this route?`)) {
      this.errorMessage = '';

      this.busStopService.delete(stop.id).subscribe({
        next: () => {
          this.stops = this.stops.filter(s => s.id !== stop.id);
          this.successMessage = 'Bus stop removed successfully!';
          this.cdr.detectChanges();
          setTimeout(() => { this.successMessage = ''; this.cdr.detectChanges(); }, 3000);
        },
        error: (error) => {
          console.error('Failed to delete bus stop:', error);
          this.errorMessage = 'Failed to remove bus stop. Please try again.';
          this.cdr.detectChanges();
        }
      });
    }
  }
}
