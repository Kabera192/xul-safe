import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiResponse, BusStop } from '../models';

@Injectable({
  providedIn: 'root'
})
export class BusStopService {
  private http = inject(HttpClient);
  private readonly basePath = '/bus-stops';

  getAll(): Observable<BusStop[]> {
    return this.http.get<ApiResponse<BusStop[]>>(`${this.basePath}`).pipe(
      map(response => response.data)
    );
  }

  getById(busStopId: string): Observable<BusStop> {
    return this.http.get<ApiResponse<BusStop>>(`${this.basePath}/${busStopId}`).pipe(
      map(response => response.data)
    );
  }

  getByRoute(routeId: number): Observable<BusStop[]> {
    return this.http.get<ApiResponse<BusStop[]>>(`${this.basePath}/route/${routeId}`).pipe(
      map(response => response.data)
    );
  }

  create(busStop: Partial<BusStop>): Observable<BusStop> {
    return this.http.post<ApiResponse<BusStop>>(`${this.basePath}`, busStop).pipe(
      map(response => response.data)
    );
  }

  update(busStopId: string, busStop: Partial<BusStop>): Observable<BusStop> {
    return this.http.put<ApiResponse<BusStop>>(`${this.basePath}/${busStopId}`, busStop).pipe(
      map(response => response.data)
    );
  }

  delete(busStopId: string): Observable<void> {
    return this.http.delete<ApiResponse<void>>(`${this.basePath}/${busStopId}`).pipe(
      map(() => void 0)
    );
  }
}
