import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiResponse, Bus, BusParentAssignment } from '../models';

@Injectable({
  providedIn: 'root'
})
export class BusService {
  private http = inject(HttpClient);
  private readonly basePath = '/buses';

  getAll(): Observable<Bus[]> {
    return this.http.get<ApiResponse<Bus[]>>(`${this.basePath}`).pipe(
      map(response => response.data)
    );
  }

  getById(busId: number): Observable<Bus> {
    return this.http.get<ApiResponse<Bus>>(`${this.basePath}/${busId}`).pipe(
      map(response => response.data)
    );
  }

  getByPlate(plateNumber: string): Observable<Bus> {
    const encodedPlate = encodeURIComponent(plateNumber);
    return this.http.get<ApiResponse<Bus>>(`${this.basePath}/plate/${encodedPlate}`).pipe(
      map(response => response.data)
    );
  }

  create(bus: Bus): Observable<Bus> {
    return this.http.post<ApiResponse<Bus>>(`${this.basePath}`, bus).pipe(
      map(response => response.data)
    );
  }

  update(busId: number, bus: Partial<Bus>): Observable<Bus> {
    return this.http.put<ApiResponse<Bus>>(`${this.basePath}/${busId}`, bus).pipe(
      map(response => response.data)
    );
  }

  delete(busId: number): Observable<void> {
    return this.http.delete<ApiResponse<void>>(`${this.basePath}/${busId}`).pipe(
      map(() => void 0)
    );
  }

  getAssignedBusForParent(parentId: number): Observable<BusParentAssignment> {
    return this.http.get<ApiResponse<BusParentAssignment>>(`${this.basePath}/parent/${parentId}/assigned`).pipe(
      map(response => response.data)
    );
  }
}
