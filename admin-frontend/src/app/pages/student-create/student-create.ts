import { Component, OnInit, inject, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { StudentService } from '../../services/student.service';
import { Router } from '@angular/router';
import { catchError, finalize, of, timeout } from 'rxjs';
import { Bus, BusStop, Child, ParentSummary, Route } from '../../models';
import { BusService } from '../../services/bus.service';
import { RouteService } from '../../services/route.service';
import { BusStopService } from '../../services/bus-stop.service';
import { UserService } from '../../services/user.service';

@Component({
  selector: 'app-student-create',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './student-create.html',
  styleUrl: './student-create.scss',
})
export class StudentCreatePage implements OnInit {
  private studentService = inject(StudentService);
  private router = inject(Router);
  private busService = inject(BusService);
  private routeService = inject(RouteService);
  private busStopService = inject(BusStopService);
  private userService = inject(UserService);
  private cdr = inject(ChangeDetectorRef);

  fullName = '';
  gender = '';
  dob = '';
  grade = '';
  selectedBusId = '';
  selectedBusStopId = '';
  photoPreview = '';
  parentId = '';
  isSaving = false;
  errorMessage = '';
  buses: Bus[] = [];
  routes: Route[] = [];
  busStops: BusStop[] = [];
  parents: ParentSummary[] = [];
  isLoadingParents = false;

  ngOnInit(): void {
    this.loadBuses();
    this.loadRoutes();
    this.loadAllParents();
  }

  /**
   * The route is never picked independently — it's always whatever route the
   * selected bus takes, so it's shown read-only and used here to filter which
   * bus stops are selectable, instead of being a separate dropdown the admin
   * could set out of sync with the bus.
   */
  get derivedRouteName(): string {
    const bus = this.buses.find(b => String(b.id) === this.selectedBusId);
    if (!this.selectedBusId || !bus) return 'Select a bus first';
    if (!bus.routeId) return 'No route assigned to this bus';
    return this.routes.find(r => r.id === bus.routeId)?.name ?? 'Unknown route';
  }

  private loadBuses(): void {
    this.busService.getAll().pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load buses:', error);
        return of([] as Bus[]);
      })
    ).subscribe((buses) => {
      this.buses = buses;
      this.cdr.detectChanges();
    });
  }

  private loadRoutes(): void {
    this.routeService.getAll().pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load routes:', error);
        return of([] as Route[]);
      })
    ).subscribe((routes) => {
      this.routes = routes;
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
    this.selectedBusStopId = '';
    const bus = this.buses.find(b => String(b.id) === this.selectedBusId);
    const routeId = bus?.routeId;
    if (!routeId) {
      this.busStops = [];
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
      this.cdr.detectChanges();
    };
    reader.readAsDataURL(file);
  }

  createStudent(): void {
    this.isSaving = true;
    this.errorMessage = '';
    this.studentService.create({
      fullName: this.fullName,
      gender: this.gender as Child['gender'],
      birthDate: this.dob,
      grade: this.grade,
      parentId: this.parentId ? Number(this.parentId) : undefined,
      photoUrl: this.photoPreview || undefined,
      busId: this.selectedBusId ? Number(this.selectedBusId) : undefined,
      busStopId: this.selectedBusStopId || undefined
    }).pipe(
      timeout(5000),
      catchError((error) => {
        this.errorMessage = error?.message || 'Failed to create student.';
        return of(null);
      }),
      finalize(() => {
        this.isSaving = false;
        this.cdr.detectChanges();
      })
    ).subscribe((child) => {
      if (child?.id) {
        this.router.navigate(['/students']);
      }
    });
  }
}
