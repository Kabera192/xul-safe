import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { StudentService } from '../../services/student.service';
import { Router } from '@angular/router';
import { catchError, finalize, of, timeout } from 'rxjs';
import { Bus, BusStop, Child, Route } from '../../models';
import { BusService } from '../../services/bus.service';
import { RouteService } from '../../services/route.service';
import { BusStopService } from '../../services/bus-stop.service';

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

  fullName = '';
  gender = '';
  dob = '';
  grade = '';
  selectedBusId = '';
  selectedRouteId = '';
  selectedBusStopId = '';
  photoPreview = '';
  parentId = '';
  isSaving = false;
  errorMessage = '';
  buses: Bus[] = [];
  routes: Route[] = [];
  busStops: BusStop[] = [];

  ngOnInit(): void {
    this.loadBuses();
    this.loadRoutes();
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
    });
  }

  onRouteChange(): void {
    this.selectedBusStopId = '';
    const routeId = Number(this.selectedRouteId);
    if (!this.selectedRouteId || Number.isNaN(routeId)) {
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
      routeId: this.selectedRouteId ? Number(this.selectedRouteId) : undefined,
      busStopId: this.selectedBusStopId || undefined
    }).pipe(
      timeout(5000),
      catchError((error) => {
        this.errorMessage = error?.message || 'Failed to create student.';
        return of(null);
      }),
      finalize(() => {
        this.isSaving = false;
      })
    ).subscribe((child) => {
      if (child?.id) {
        this.router.navigate(['/students']);
      }
    });
  }
}
