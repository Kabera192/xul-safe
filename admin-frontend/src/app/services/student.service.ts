import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiResponse, Child, ChildDetail } from '../models';

@Injectable({
  providedIn: 'root'
})
export class StudentService {
  private http = inject(HttpClient);
  private readonly basePath = '/children';

  /**
   * Get all children (admin endpoint).
   * Requires GET /children endpoint in backend.
   */
  getAll(): Observable<Child[]> {
    return this.http.get<ApiResponse<Child[]>>(`${this.basePath}`).pipe(
      map(response => response.data)
    );
  }

  /**
   * Get all children (admin endpoint).
   * GET /children/all
   */
  getAllAdmin(): Observable<Child[]> {
    return this.http.get<ApiResponse<Child[]>>(`${this.basePath}/all`).pipe(
      map(response => response.data)
    );
  }

  /**
   * Get all children with enriched data (admin endpoint).
   * Returns bus, route, and bus stop names.
   * GET /children/admin/details
   */
  getAllWithDetails(): Observable<ChildDetail[]> {
    return this.http.get<ApiResponse<ChildDetail[]>>(`${this.basePath}/admin/details`).pipe(
      map(response => response.data)
    );
  }

  getByParent(parentId: number): Observable<Child[]> {
    return this.http.get<ApiResponse<Child[]>>(`${this.basePath}/parent/${parentId}`).pipe(
      map(response => response.data)
    );
  }

  getById(childId: string): Observable<Child> {
    return this.http.get<ApiResponse<Child>>(`${this.basePath}/${childId}`).pipe(
      map(response => response.data)
    );
  }

  /**
   * Get a single child with enriched data (admin endpoint).
   * Returns bus, route, and bus stop names.
   * GET /children/admin/details/{childId}
   */
  getByIdWithDetails(childId: string): Observable<ChildDetail> {
    return this.http.get<ApiResponse<ChildDetail>>(`${this.basePath}/admin/details/${childId}`).pipe(
      map(response => response.data)
    );
  }

  create(child: Child): Observable<Child> {
    return this.http.post<ApiResponse<Child>>(`${this.basePath}`, child).pipe(
      map(response => response.data)
    );
  }

  update(childId: string, child: Partial<Child>): Observable<Child> {
    return this.http.put<ApiResponse<Child>>(`${this.basePath}/${childId}`, child).pipe(
      map(response => response.data)
    );
  }

  delete(childId: string): Observable<void> {
    return this.http.delete<ApiResponse<void>>(`${this.basePath}/${childId}`).pipe(
      map(() => void 0)
    );
  }
}
