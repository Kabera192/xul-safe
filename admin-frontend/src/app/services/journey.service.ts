import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiResponse, Journey, JourneySummary, WeeklyAttendance } from '../models';

@Injectable({
  providedIn: 'root'
})
export class JourneyService {
  private http = inject(HttpClient);
  private readonly basePath = '/journeys';

  // Parent-specific methods
  getByParent(childIds: string[]): Observable<Journey[]> {
    return this.http.post<ApiResponse<Journey[]>>(`${this.basePath}/parent`, { childIds }).pipe(
      map(response => response.data)
    );
  }

  getSummary(childIds: string[]): Observable<JourneySummary> {
    return this.http.post<ApiResponse<JourneySummary>>(`${this.basePath}/parent/summary`, { childIds }).pipe(
      map(response => response.data)
    );
  }

  createSampleJourneys(childIds: string[]): Observable<void> {
    return this.http.post<ApiResponse<void>>(`${this.basePath}/sample`, { childIds }).pipe(
      map(() => void 0)
    );
  }

  // Admin methods
  getAll(): Observable<Journey[]> {
    return this.http.get<ApiResponse<Journey[]>>(this.basePath).pipe(
      map(response => response.data)
    );
  }

  getByDateRange(startDate: string, endDate: string): Observable<Journey[]> {
    const params = new HttpParams()
      .set('startDate', startDate)
      .set('endDate', endDate);
    return this.http.get<ApiResponse<Journey[]>>(`${this.basePath}/range`, { params }).pipe(
      map(response => response.data)
    );
  }

  getWeeklyAttendance(weekStart: string): Observable<WeeklyAttendance[]> {
    const params = new HttpParams().set('weekStart', weekStart);
    return this.http.get<ApiResponse<WeeklyAttendance[]>>(`${this.basePath}/attendance/weekly`, { params }).pipe(
      map(response => response.data)
    );
  }
}
