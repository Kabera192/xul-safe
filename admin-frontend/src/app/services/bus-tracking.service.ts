import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiResponse, BusTracking, StartJourneyRequest, LocationUpdate, StatusUpdate, BusTrackingStatus, BusTripStatusToday } from '../models';

@Injectable({
  providedIn: 'root'
})
export class BusTrackingService {
  private http = inject(HttpClient);
  private readonly basePath = '/bus-tracking';

  getForChild(childId: string): Observable<BusTracking | null> {
    return this.http.get<ApiResponse<BusTracking>>(`${this.basePath}/child/${childId}`).pipe(
      map(response => response.data)
    );
  }

  getForRoute(routeId: number): Observable<BusTracking | null> {
    return this.http.get<ApiResponse<BusTracking>>(`${this.basePath}/route/${routeId}`).pipe(
      map(response => response.data)
    );
  }

  /** Today's trip status (SCHEDULED / IN_PROGRESS / COMPLETED) for every bus with a route assigned. */
  getTodayStatuses(): Observable<BusTripStatusToday[]> {
    return this.http.get<ApiResponse<BusTripStatusToday[]>>(`${this.basePath}/today-status`).pipe(
      map(response => response.data)
    );
  }

  startJourney(data: StartJourneyRequest): Observable<BusTracking> {
    return this.http.post<ApiResponse<BusTracking>>(`${this.basePath}/start`, data).pipe(
      map(response => response.data)
    );
  }

  updateLocation(trackingId: string, location: LocationUpdate): Observable<BusTracking> {
    return this.http.put<ApiResponse<BusTracking>>(`${this.basePath}/${trackingId}/location`, location).pipe(
      map(response => response.data)
    );
  }

  updateStatus(trackingId: string, status: BusTrackingStatus): Observable<BusTracking> {
    return this.http.put<ApiResponse<BusTracking>>(`${this.basePath}/${trackingId}/status`, { status }).pipe(
      map(response => response.data)
    );
  }

  endJourney(trackingId: string): Observable<void> {
    return this.http.post<ApiResponse<void>>(`${this.basePath}/${trackingId}/end`, {}).pipe(
      map(() => void 0)
    );
  }
}
