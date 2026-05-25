import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiResponse, Conductor } from '../models';

@Injectable({
  providedIn: 'root'
})
export class ConductorService {
  private http = inject(HttpClient);
  private readonly basePath = '/drivers';

  getAll(): Observable<Conductor[]> {
    return this.http.get<ApiResponse<Conductor[]>>(`${this.basePath}`).pipe(
      map(response => response.data)
    );
  }

  getById(conductorId: number): Observable<Conductor> {
    return this.http.get<ApiResponse<Conductor>>(`${this.basePath}/${conductorId}`).pipe(
      map(response => response.data)
    );
  }

  create(conductor: Conductor): Observable<Conductor> {
    return this.http.post<ApiResponse<Conductor>>(`${this.basePath}`, conductor).pipe(
      map(response => response.data)
    );
  }

  update(conductorId: number, conductor: Partial<Conductor>): Observable<Conductor> {
    return this.http.put<ApiResponse<Conductor>>(`${this.basePath}/${conductorId}`, conductor).pipe(
      map(response => response.data)
    );
  }

  delete(conductorId: number): Observable<void> {
    return this.http.delete<ApiResponse<void>>(`${this.basePath}/${conductorId}`).pipe(
      map(() => void 0)
    );
  }
}
