import { ChangeDetectorRef, Component, OnDestroy, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { StudentService } from '../../services/student.service';
import { BusService } from '../../services/bus.service';
import { RouteService } from '../../services/route.service';
import { BusStopService } from '../../services/bus-stop.service';
import { Child, ChildDetail, Bus, Route, BusStop } from '../../models';
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
  selectedRouteId: number | null = null;
  selectedBusStopId: string | null = null;
  photoPreview = '';
  parentId = '';
  isSaving = false;
  isLoading = false;
  errorMessage = '';

  // Dropdown options
  buses: Bus[] = [];
  routes: Route[] = [];
  busStops: BusStop[] = [];

  ngOnInit(): void {
    this.loadDropdownOptions();
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
    this.selectedRouteId = null;
    this.selectedBusStopId = null;
    this.photoPreview = '';
    this.parentId = '';
    this.errorMessage = '';
  }

  private loadDropdownOptions(): void {
    forkJoin({
      buses: this.busService.getAll().pipe(catchError(() => of([]))),
      routes: this.routeService.getAll().pipe(catchError(() => of([]))),
      busStops: this.busStopService.getAll().pipe(catchError(() => of([])))
    }).subscribe(({ buses, routes, busStops }) => {
      this.buses = buses;
      this.routes = routes;
      this.busStops = busStops;
      this.cdr.detectChanges();
    });
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
      this.selectedRouteId = student.routeId ?? null;
      this.selectedBusStopId = student.busStopId ?? null;
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
      routeId: this.selectedRouteId ?? undefined,
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
