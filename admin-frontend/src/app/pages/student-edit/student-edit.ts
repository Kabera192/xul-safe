import { ChangeDetectorRef, Component, OnDestroy, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { StudentService } from '../../services/student.service';
import { BusService } from '../../services/bus.service';
import { RouteService } from '../../services/route.service';
import { BusStopService } from '../../services/bus-stop.service';
import { UserService } from '../../services/user.service';
import { Child, ChildDetail, Bus, Route, BusStop, ParentSummary } from '../../models';
import { Subscription, catchError, finalize, forkJoin, of, timeout } from 'rxjs';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-student-edit',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './student-edit.html',
  styleUrl: './student-edit.scss',
})
export class StudentEditPage implements OnInit, OnDestroy {
  private studentService = inject(StudentService);
  private busService = inject(BusService);
  private routeService = inject(RouteService);
  private busStopService = inject(BusStopService);
  private userService = inject(UserService);
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  private cdr = inject(ChangeDetectorRef);
  private routeSub?: Subscription;

  studentId = '';
  fullName = '';
  gender = '';
  dob = '';
  grade = '';
  selectedBusId: number | null = null;
  selectedBusStopId: string | null = null;
  photoPreview = '';
  parentId = '';
  isSaving = false;
  isLoading = false;
  errorMessage = '';
  noticeMessage = '';
  private dropdownsLoaded = false;
  private studentApplied = false;

  // Dropdown options
  buses: Bus[] = [];
  routes: Route[] = [];
  busStops: BusStop[] = [];
  parents: ParentSummary[] = [];
  isLoadingParents = false;

  ngOnInit(): void {
    this.loadDropdownOptions();
    this.loadAllParents();
    this.routeSub = this.route.paramMap.subscribe((params) => {
      const id = params.get('id');
      this.resetFormState();
      if (!id) {
        return;
      }
      this.studentId = id;
      this.loadStudent(this.studentId);
    });
  }

  ngOnDestroy(): void {
    this.routeSub?.unsubscribe();
  }

  private resetFormState(): void {
    this.studentId = '';
    this.fullName = '';
    this.gender = '';
    this.dob = '';
    this.grade = '';
    this.selectedBusId = null;
    this.selectedBusStopId = null;
    this.busStops = [];
    this.photoPreview = '';
    this.parentId = '';
    this.parents = [];
    this.errorMessage = '';
    this.noticeMessage = '';
    this.studentApplied = false;
  }

  private loadDropdownOptions(): void {
    forkJoin({
      buses: this.busService.getAll().pipe(catchError(() => of([]))),
      routes: this.routeService.getAll().pipe(catchError(() => of([])))
    }).subscribe(({ buses, routes }) => {
      this.buses = buses;
      this.routes = routes;
      this.dropdownsLoaded = true;
      this.afterCoreDataReady();
      this.cdr.detectChanges();
    });
  }

  /**
   * A student can reference a bus that was since deleted elsewhere. The
   * <select> then shows nothing selected (no matching <option>), but the
   * stale ID was still sitting in the bound field and would otherwise be
   * submitted as-is, producing a confusing "not found" error for a field
   * that looks blank. Clear it so a visibly blank field behaves as blank.
   *
   * The dropdown options and the student itself load via independent async
   * calls with no guaranteed order — wait until both have actually landed
   * before checking, otherwise a list that just hasn't arrived yet looks
   * identical to "this ID doesn't exist" and gets wrongly cleared.
   */
  private afterCoreDataReady(): void {
    if (!this.dropdownsLoaded || !this.studentApplied) {
      return;
    }

    const staleBus = this.selectedBusId !== null &&
      !this.buses.some((b) => b.id === this.selectedBusId);

    if (staleBus) {
      this.selectedBusId = null;
      this.selectedBusStopId = null;
      this.noticeMessage = 'The previously assigned bus is no longer available. Please select one if needed.';
    }

    this.loadBusStopsForCurrentBus(true);
  }

  /**
   * Bus stops are scoped to whichever route the selected bus takes — a stop
   * on a different route isn't reachable by this bus, so it has no business
   * showing up as a pickable option here (matches student-create.ts).
   */
  private loadBusStopsForCurrentBus(preserveSelection: boolean): void {
    if (!preserveSelection) {
      this.selectedBusStopId = null;
    }
    const bus = this.buses.find(b => b.id === this.selectedBusId);
    const routeId = bus?.routeId;
    if (!routeId) {
      this.busStops = [];
      if (preserveSelection) {
        this.selectedBusStopId = null;
      }
      this.cdr.detectChanges();
      return;
    }
    this.busStopService.getByRoute(routeId).pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load bus stops:', error);
        return of([] as BusStop[]);
      })
    ).subscribe((stops) => {
      this.busStops = stops;
      if (preserveSelection && this.selectedBusStopId !== null &&
          !stops.some((s) => s.id === this.selectedBusStopId)) {
        this.selectedBusStopId = null;
        this.noticeMessage = 'The previously assigned bus stop is no longer available on this route. Please select one if needed.';
      }
      this.cdr.detectChanges();
    });
  }

  private loadAllParents(): void {
    this.isLoadingParents = true;
    this.userService.getAllParents().pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load parents:', error);
        return of([] as ParentSummary[]);
      }),
      finalize(() => {
        this.isLoadingParents = false;
        this.cdr.detectChanges();
      })
    ).subscribe((parents) => {
      this.parents = parents;
      this.cdr.detectChanges();
    });
  }

  onBusChange(): void {
    this.loadBusStopsForCurrentBus(false);
  }

  private loadStudent(studentId: string): void {
    this.isLoading = true;
    this.cdr.detectChanges();

    this.studentService.getByIdWithDetails(studentId).pipe(
      timeout(10000),
      catchError((error) => {
        console.error('Failed to load student:', error);
        this.errorMessage = error?.message || 'Failed to load student.';
        return of(null as ChildDetail | null);
      }),
      finalize(() => {
        this.isLoading = false;
        this.cdr.detectChanges();
      })
    ).subscribe((student) => {
      if (!student) {
        return;
      }
      console.log('Student loaded:', student);
      this.fullName = student.fullName ?? '';
      this.gender = student.gender ?? '';
      this.dob = this.normalizeDate(student.birthDate);
      this.grade = student.grade ?? '';
      this.parentId = String(student.parentId ?? '');
      this.photoPreview = this.normalizePhotoUrl(student.photoUrl);
      this.selectedBusId = student.busId ?? null;
      this.selectedBusStopId = student.busStopId ?? null;
      this.studentApplied = true;
      this.afterCoreDataReady();
      this.cdr.detectChanges();
    });
  }

  /**
   * The route is never picked independently — it's always whatever route the
   * selected bus takes, so it's shown read-only and derived here instead of
   * being a separate dropdown the admin could set out of sync with the bus.
   */
  get derivedRouteName(): string {
    if (!this.selectedBusId) return 'Select a bus first';
    const bus = this.buses.find(b => b.id === this.selectedBusId);
    if (!bus?.routeId) return 'No route assigned to this bus';
    return this.routes.find(r => r.id === bus.routeId)?.name ?? 'Unknown route';
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
      this.cdr.detectChanges();
    };
    reader.readAsDataURL(file);
  }

  saveChanges(): void {
    if (!this.studentId) {
      return;
    }
    this.isSaving = true;
    this.errorMessage = '';
    this.cdr.detectChanges();

    this.studentService.update(this.studentId, {
      fullName: this.fullName,
      gender: this.gender as Child['gender'],
      birthDate: this.dob,
      grade: this.grade,
      parentId: Number(this.parentId || 0),
      photoUrl: this.photoPreview || undefined,
      busId: this.selectedBusId ?? undefined,
      busStopId: this.selectedBusStopId ?? undefined
    }).pipe(
      timeout(10000),
      finalize(() => {
        this.isSaving = false;
        this.cdr.detectChanges();
      })
    ).subscribe({
      next: () => {
        this.router.navigate(['/students']);
      },
      error: (error) => {
        console.error('Failed to update student:', error);
        this.errorMessage = error?.message || 'Failed to update student.';
        this.cdr.detectChanges();
      }
    });
  }

  private normalizeDate(dateValue?: string): string {
    if (!dateValue) {
      return '';
    }
    const parsed = new Date(dateValue);
    if (Number.isNaN(parsed.getTime())) {
      return dateValue;
    }
    const year = parsed.getFullYear();
    const month = String(parsed.getMonth() + 1).padStart(2, '0');
    const day = String(parsed.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
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
