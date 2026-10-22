import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { RouteService } from '../../services/route.service';
import { StudentService } from '../../services/student.service';
import { UserService } from '../../services/user.service';
import { ChildDetail, Route, RouteRequest, RouteRequestStatus, User } from '../../models';
import { catchError, finalize, forkJoin, of, timeout } from 'rxjs';
import { MapPickerComponent } from '../../shared/map-picker/map-picker.component';

@Component({
  selector: 'app-request-details',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, MapPickerComponent],
  templateUrl: './request-details.html',
  styleUrl: './request-details.scss',
})
export class RequestDetailsPage implements OnInit {
  private route = inject(ActivatedRoute);
  private routeService = inject(RouteService);
  private studentService = inject(StudentService);
  private userService = inject(UserService);
  private cdr = inject(ChangeDetectorRef);

  requestId = '';
  isLoading = false;
  errorMessage = '';
  request: RouteRequest | null = null;
  child: ChildDetail | null = null;
  parent: User | null = null;
  isUpdatingStatus = false;
  updatingToStatus: RouteRequestStatus | null = null;
  statusActionError = '';
  statusActionSuccess = '';

  // Approving a request requires picking which route the new stop
  // belongs to — the backend creates and assigns the stop under it.
  routes: Route[] = [];
  selectedRouteId: number | null = null;

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (!id) {
      this.errorMessage = 'Request not found.';
      return;
    }
    this.requestId = id;
    const numericId = Number(id);
    if (Number.isNaN(numericId)) {
      this.errorMessage = 'Invalid request ID.';
      return;
    }
    this.loadRequest(numericId);
    this.routeService.getAll().pipe(
      catchError(() => of([] as Route[]))
    ).subscribe((routes) => {
      this.routes = routes;
      this.cdr.detectChanges();
    });
  }

  private loadRequest(requestId: number): void {
    this.isLoading = true;
    this.errorMessage = '';
    const fallbackTimer = window.setTimeout(() => {
      if (this.isLoading) {
        this.isLoading = false;
        this.errorMessage = 'Failed to load request. Please try again.';
        this.cdr.detectChanges();
      }
    }, 5000);

    this.routeService.getRouteRequestById(requestId).pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load route request:', error);
        this.errorMessage = error?.message || 'Failed to load request.';
        return of(null as RouteRequest | null);
      })
    ).subscribe((request) => {
      if (!request) {
        this.isLoading = false;
        window.clearTimeout(fallbackTimer);
        this.cdr.detectChanges();
        return;
      }
      this.request = request;
      this.statusActionError = '';
      this.statusActionSuccess = '';
      const childId = request.childId;
      const parentId = request.parentId;

      forkJoin({
        child: childId
          ? this.studentService.getByIdWithDetails(childId).pipe(catchError(() => of(null as ChildDetail | null)))
          : of(null as ChildDetail | null),
        parent: parentId != null
          ? this.userService.getProfile(parentId).pipe(catchError(() => of(null as User | null)))
          : of(null as User | null)
      }).pipe(
        finalize(() => {
          this.isLoading = false;
          window.clearTimeout(fallbackTimer);
          this.cdr.detectChanges();
        })
      ).subscribe(({ child, parent }) => {
        this.child = child;
        this.parent = parent;
        this.cdr.detectChanges();
      });
    });
  }

  onConfirmRequest(): void {
    if (this.selectedRouteId == null) {
      this.statusActionError = 'Pick a route before confirming this request.';
      this.statusActionSuccess = '';
      return;
    }
    this.updateRequestStatus('APPROVED', this.selectedRouteId);
  }

  onDeclineRequest(): void {
    this.updateRequestStatus('REJECTED');
  }

  get isConfirmDisabled(): boolean {
    return this.isUpdatingStatus || this.requestStatus === 'APPROVED' || this.selectedRouteId == null;
  }

  get isDeclineDisabled(): boolean {
    return this.isUpdatingStatus || this.requestStatus === 'REJECTED';
  }

  get confirmButtonText(): string {
    return this.isUpdatingStatus && this.updatingToStatus === 'APPROVED'
      ? 'Saving...'
      : 'Confirm request';
  }

  get declineButtonText(): string {
    return this.isUpdatingStatus && this.updatingToStatus === 'REJECTED'
      ? 'Saving...'
      : 'Decline request';
  }

  private updateRequestStatus(status: RouteRequestStatus, routeId?: number): void {
    if (this.isUpdatingStatus || !this.request?.id) {
      return;
    }

    if (this.requestStatus === status) {
      this.statusActionError = '';
      this.statusActionSuccess = `Request is already ${status.toLowerCase()}.`;
      return;
    }

    this.isUpdatingStatus = true;
    this.updatingToStatus = status;
    this.statusActionError = '';
    this.statusActionSuccess = '';

    this.routeService.updateRouteRequestStatus(this.request.id, status, routeId).pipe(
      catchError((error) => {
        console.error('Failed to update route request status:', error);
        this.statusActionError = error?.message || 'Failed to update request status.';
        return of(null as RouteRequest | null);
      }),
      finalize(() => {
        this.isUpdatingStatus = false;
        this.updatingToStatus = null;
        this.cdr.detectChanges();
      })
    ).subscribe((updatedRequest) => {
      if (!updatedRequest) {
        return;
      }

      this.request = {
        ...this.request,
        ...updatedRequest
      };
      this.statusActionSuccess = status === 'APPROVED'
        ? 'Request confirmed successfully.'
        : 'Request declined successfully.';
      this.statusActionError = '';
      this.cdr.detectChanges();
    });
  }

  get hasLocation(): boolean {
    return this.getCoordinates() !== null;
  }

  private getCoordinates(): { lat: number; lng: number } | null {
    const latitude = Number(this.request?.latitude);
    const longitude = Number(this.request?.longitude);
    if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
      return null;
    }
    return { lat: latitude, lng: longitude };
  }

  get requestAddress(): string {
    return this.request?.address ?? 'N/A';
  }

  get requestDescription(): string {
    return this.request?.description ?? 'N/A';
  }

  get requestStatus(): RouteRequestStatus {
    const status = this.request?.status;
    if (status === 'APPROVED' || status === 'REJECTED' || status === 'PENDING') {
      return status;
    }
    return 'PENDING';
  }

  get pickedLat(): number | null {
    return this.getCoordinates()?.lat ?? null;
  }

  get pickedLng(): number | null {
    return this.getCoordinates()?.lng ?? null;
  }

  get childName(): string {
    return this.child?.fullName ?? 'Unknown child';
  }

  get parentPhone(): string {
    return this.parent?.phoneNumber ?? 'N/A';
  }

  get parentEmail(): string {
    return this.parent?.email ?? 'N/A';
  }
}
