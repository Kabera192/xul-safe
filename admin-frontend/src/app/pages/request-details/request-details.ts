import { AfterViewInit, ChangeDetectorRef, Component, ElementRef, OnInit, ViewChild, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { RouteService } from '../../services/route.service';
import { StudentService } from '../../services/student.service';
import { UserService } from '../../services/user.service';
import { ChildDetail, RouteRequest, RouteRequestStatus, User } from '../../models';
import { catchError, finalize, forkJoin, of, timeout } from 'rxjs';

declare const google: any;

@Component({
  selector: 'app-request-details',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './request-details.html',
  styleUrl: './request-details.scss',
})
export class RequestDetailsPage implements OnInit, AfterViewInit {
  private route = inject(ActivatedRoute);
  private routeService = inject(RouteService);
  private studentService = inject(StudentService);
  private userService = inject(UserService);
  private cdr = inject(ChangeDetectorRef);
  private sanitizer = inject(DomSanitizer);
  private mapsLoader?: Promise<void>;

  @ViewChild('mapContainer') mapContainer?: ElementRef<HTMLDivElement>;

  requestId = '';
  isLoading = false;
  errorMessage = '';
  request: RouteRequest | null = null;
  child: ChildDetail | null = null;
  parent: User | null = null;
  mapError = '';
  isUpdatingStatus = false;
  updatingToStatus: RouteRequestStatus | null = null;
  statusActionError = '';
  statusActionSuccess = '';
  private map?: any;
  private marker?: any;
  private viewReady = false;

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
  }

  ngAfterViewInit(): void {
    this.viewReady = true;
    this.tryInitMapSoon();
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
      this.tryInitMapSoon();
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
        this.tryInitMapSoon();
        this.cdr.detectChanges();
      });
    });
  }

  private tryInitMapSoon(): void {
    setTimeout(() => this.initMapIfReady(), 0);
  }

  private initMapIfReady(): void {
    const coordinates = this.getCoordinates();
    if (!this.viewReady || !this.mapContainer || !coordinates) {
      return;
    }
    this.loadGoogleMaps()
      .then(() => {
        const position = coordinates;

        if (!this.map) {
          this.map = new google.maps.Map(this.mapContainer!.nativeElement, {
            center: position,
            zoom: 15,
            mapTypeControl: false,
            streetViewControl: false
          });
          this.marker = new google.maps.Marker({
            position,
            map: this.map
          });
        } else {
          this.map.setCenter(position);
          if (this.marker) {
            this.marker.setPosition(position);
          }
        }
      })
      .catch((error) => {
        console.error('Failed to load Google Maps:', error);
        this.mapError = 'Map unavailable.';
        this.cdr.detectChanges();
      });
  }

  private loadGoogleMaps(): Promise<void> {
    if (typeof google !== 'undefined' && google.maps) {
      return Promise.resolve();
    }
    if (this.mapsLoader) {
      return this.mapsLoader;
    }
    this.mapsLoader = new Promise((resolve, reject) => {
      const scriptId = 'google-maps-sdk';
      const existing = document.getElementById(scriptId) as HTMLScriptElement | null;
      if (existing) {
        if (typeof google !== 'undefined' && google.maps) {
          resolve();
          return;
        }

        const onLoad = () => {
          existing.removeEventListener('error', onError);
          if (typeof google !== 'undefined' && google.maps) {
            resolve();
            return;
          }
          reject(new Error('Google Maps loaded without maps API'));
        };
        const onError = () => {
          existing.removeEventListener('load', onLoad);
          reject(new Error('Failed to load Google Maps'));
        };

        existing.addEventListener('load', onLoad, { once: true });
        existing.addEventListener('error', onError, { once: true });
        return;
      }
      const script = document.createElement('script');
      script.id = scriptId;
      script.src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyDvXoER4O7m0dtJUynP2zQV_3vQ5WZs2B4';
      script.async = true;
      script.defer = true;
      script.onload = () => {
        if (typeof google !== 'undefined' && google.maps) {
          resolve();
          return;
        }
        reject(new Error('Google Maps loaded without maps API'));
      };
      script.onerror = () => reject(new Error('Failed to load Google Maps'));
      document.head.appendChild(script);
    });
    return this.mapsLoader;
  }

  onConfirmRequest(): void {
    this.updateRequestStatus('APPROVED');
  }

  onDeclineRequest(): void {
    this.updateRequestStatus('REJECTED');
  }

  get isConfirmDisabled(): boolean {
    return this.isUpdatingStatus || this.requestStatus === 'APPROVED';
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

  private updateRequestStatus(status: RouteRequestStatus): void {
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

    this.routeService.updateRouteRequestStatus(this.request.id, status).pipe(
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

  get mapFallbackUrl(): SafeResourceUrl | null {
    const coordinates = this.getCoordinates();
    if (!coordinates) {
      return null;
    }
    return this.sanitizer.bypassSecurityTrustResourceUrl(
      `https://www.google.com/maps?q=${coordinates.lat},${coordinates.lng}&z=15&output=embed`
    );
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
