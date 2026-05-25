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
}
