import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiResponse, Absence } from '../models';

@Injectable({
  providedIn: 'root'
})
export class AbsenceService {
  private http = inject(HttpClient);
  private readonly basePath = '/absences';

  getAll(): Observable<Absence[]> {
    return this.http.get<ApiResponse<Absence[]>>(`${this.basePath}/all`).pipe(
      map(response => response.data)
    );
  }

  getForChild(childId: string): Observable<Absence[]> {
    return this.http.get<ApiResponse<Absence[]>>(`${this.basePath}`, {
      params: { child_id: childId }
    }).pipe(map(response => response.data));
  }

  getForParent(parentId: number): Observable<Absence[]> {
    return this.http.get<ApiResponse<Absence[]>>(`${this.basePath}/parent/${parentId}`).pipe(
      map(response => response.data)
    );
  }

  getActiveForParent(parentId: number): Observable<Absence[]> {
    return this.http.get<ApiResponse<Absence[]>>(`${this.basePath}/parent/${parentId}/active`).pipe(
      map(response => response.data)
    );
  }

  create(absence: Absence): Observable<Absence> {
    return this.http.post<ApiResponse<Absence>>(`${this.basePath}`, absence).pipe(
      map(response => response.data)
    );
  }

  update(absenceId: number, absence: Partial<Absence>): Observable<Absence> {
    return this.http.put<ApiResponse<Absence>>(`${this.basePath}/${absenceId}`, absence).pipe(
      map(response => response.data)
    );
  }

  delete(absenceId: number): Observable<void> {
    return this.http.delete<ApiResponse<void>>(`${this.basePath}/${absenceId}`).pipe(
      map(() => void 0)
    );
  }

  complete(absenceId: number): Observable<Absence> {
    return this.http.post<ApiResponse<Absence>>(`${this.basePath}/${absenceId}/complete`, {}).pipe(
      map(response => response.data)
    );
  }
}
