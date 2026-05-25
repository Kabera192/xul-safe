import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiResponse, ChildRoute, ChildRouteDetails, Route, RouteRequest, RouteRequestStatus, SelectBusStopRequest } from '../models';

@Injectable({
  providedIn: 'root'
})
export class RouteService {
  private http = inject(HttpClient);
  private readonly basePath = '/routes';

  // Route CRUD operations
  getAll(): Observable<Route[]> {
    return this.http.get<ApiResponse<Route[]>>(`${this.basePath}`).pipe(
      map(response => response.data)
    );
  }

  getById(routeId: number): Observable<Route> {
    return this.http.get<ApiResponse<Route>>(`${this.basePath}/${routeId}`).pipe(
      map(response => response.data)
    );
  }

  create(route: Route): Observable<Route> {
    return this.http.post<ApiResponse<Route>>(`${this.basePath}`, route).pipe(
      map(response => response.data)
    );
  }

  update(routeId: number, route: Partial<Route>): Observable<Route> {
    return this.http.put<ApiResponse<Route>>(`${this.basePath}/${routeId}`, route).pipe(
      map(response => response.data)
    );
  }

  delete(routeId: number): Observable<void> {
    return this.http.delete<ApiResponse<void>>(`${this.basePath}/${routeId}`).pipe(
      map(() => void 0)
    );
  }

  // Child route operations
  getChildRoute(childId: string): Observable<ChildRoute | null> {
    return this.http.get<ApiResponse<ChildRoute>>(`${this.basePath}/child/${childId}`).pipe(
      map(response => response.data)
    );
  }

  getChildRouteDetails(childId: string): Observable<ChildRouteDetails> {
    return this.http.get<ApiResponse<ChildRouteDetails>>(`${this.basePath}/child/${childId}/details`).pipe(
      map(response => response.data)
    );
  }

  submitRouteRequest(request: RouteRequest): Observable<RouteRequest> {
    return this.http.post<ApiResponse<RouteRequest>>(`${this.basePath}/requests`, request).pipe(
      map(response => response.data)
    );
  }

  getRouteRequests(): Observable<RouteRequest[]> {
    return this.http.get<ApiResponse<RouteRequest[]>>(`${this.basePath}/requests`).pipe(
      map(response => response.data)
    );
  }

  getRouteRequestById(requestId: number): Observable<RouteRequest> {
    return this.http.get<ApiResponse<RouteRequest>>(`${this.basePath}/requests/${requestId}`).pipe(
      map(response => response.data)
    );
  }

  updateRouteRequestStatus(requestId: number, status: RouteRequestStatus): Observable<RouteRequest> {
    return this.http.put<ApiResponse<RouteRequest>>(
      `${this.basePath}/requests/${requestId}/status`,
      { status }
    ).pipe(
      map(response => response.data)
    );
  }

  selectBusStop(request: SelectBusStopRequest): Observable<SelectBusStopRequest> {
    return this.http.post<ApiResponse<SelectBusStopRequest>>(`${this.basePath}/select-bus-stop`, request).pipe(
      map(response => response.data)
    );
  }
}
