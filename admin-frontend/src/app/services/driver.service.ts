import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import {
  ApiResponse,
  DriverBus,
  DriverRoute,
  DriverStop,
  DriverChild,
  CreateStopRequest,
  UpdateStopRequest,
  AssignChildrenToStopRequest,
} from '../models';

@Injectable({
  providedIn: 'root'
})
export class DriverService {
  private http = inject(HttpClient);
  private readonly basePath = '/me';

  // ── Transport ────────────────────────────────────────────────────────────────

  getBus(): Observable<DriverBus> {
    return this.http.get<ApiResponse<DriverBus>>(`${this.basePath}/bus`).pipe(
      map(response => response.data)
    );
  }

  getRoute(): Observable<DriverRoute> {
    return this.http.get<ApiResponse<DriverRoute>>(`${this.basePath}/bus/route`).pipe(
      map(response => response.data)
    );
  }

  getRouteStops(): Observable<DriverStop[]> {
    return this.http.get<ApiResponse<DriverStop[]>>(`${this.basePath}/bus/route/stops`).pipe(
      map(response => response.data)
    );
  }

  addRouteStop(stop: CreateStopRequest): Observable<DriverStop> {
    return this.http.post<ApiResponse<DriverStop>>(`${this.basePath}/bus/route/stops`, stop).pipe(
      map(response => response.data)
    );
  }

  updateRouteStop(stopId: number, stop: UpdateStopRequest): Observable<DriverStop> {
    return this.http.patch<ApiResponse<DriverStop>>(`${this.basePath}/bus/route/stops/${stopId}`, stop).pipe(
      map(response => response.data)
    );
  }

  deleteRouteStop(stopId: number): Observable<void> {
    return this.http.delete<ApiResponse<void>>(`${this.basePath}/bus/route/stops/${stopId}`).pipe(
      map(() => void 0)
    );
  }

  // ── Children ─────────────────────────────────────────────────────────────────

  getChildren(): Observable<DriverChild[]> {
    return this.http.get<ApiResponse<DriverChild[]>>(`${this.basePath}/bus/children`).pipe(
      map(response => response.data)
    );
  }

  getChild(childId: string): Observable<DriverChild> {
    return this.http.get<ApiResponse<DriverChild>>(`${this.basePath}/bus/children/${childId}`).pipe(
      map(response => response.data)
    );
  }

  getAbsentChildren(date: string, journey: 'MORNING' | 'RETURN'): Observable<DriverChild[]> {
    const params = new HttpParams().set('date', date).set('journey', journey);
    return this.http.get<ApiResponse<DriverChild[]>>(`${this.basePath}/bus/children/absent`, { params }).pipe(
      map(response => response.data)
    );
  }

  getPresentChildren(date: string, journey: 'MORNING' | 'RETURN'): Observable<DriverChild[]> {
    const params = new HttpParams().set('date', date).set('journey', journey);
    return this.http.get<ApiResponse<DriverChild[]>>(`${this.basePath}/bus/children/present`, { params }).pipe(
      map(response => response.data)
    );
  }

  assignChildrenToStop(stopId: number, request: AssignChildrenToStopRequest): Observable<void> {
    return this.http.patch<ApiResponse<void>>(`${this.basePath}/bus/children/assign-to-stop/${stopId}`, request).pipe(
      map(() => void 0)
    );
  }
}
