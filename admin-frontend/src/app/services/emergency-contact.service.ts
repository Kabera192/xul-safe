import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiResponse, EmergencyContact } from '../models';

@Injectable({
  providedIn: 'root'
})
export class EmergencyContactService {
  private http = inject(HttpClient);
  private readonly basePath = '/emergency-contacts';

  getByParent(parentId: number): Observable<EmergencyContact[]> {
    return this.http.get<ApiResponse<EmergencyContact[]>>(`${this.basePath}/${parentId}`).pipe(
      map(response => response.data)
    );
  }

  create(contact: EmergencyContact): Observable<EmergencyContact> {
    return this.http.post<ApiResponse<EmergencyContact>>(`${this.basePath}`, contact).pipe(
      map(response => response.data)
    );
  }

  update(contactId: number, contact: Partial<EmergencyContact>): Observable<EmergencyContact> {
    return this.http.put<ApiResponse<EmergencyContact>>(`${this.basePath}/${contactId}`, contact).pipe(
      map(response => response.data)
    );
  }

  delete(parentId: number, contactId: number): Observable<void> {
    return this.http.delete<ApiResponse<void>>(`${this.basePath}/${parentId}/${contactId}`).pipe(
      map(() => void 0)
    );
  }
}
