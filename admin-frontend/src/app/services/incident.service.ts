import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiResponse, Incident, IncidentAttachment } from '../models';

@Injectable({
  providedIn: 'root'
})
export class IncidentService {
  private http = inject(HttpClient);
  private readonly basePath = '/incidents';

  getAll(): Observable<Incident[]> {
    return this.http.get<ApiResponse<Incident[]>>(`${this.basePath}`).pipe(
      map(response => response.data)
    );
  }

  getById(incidentId: number): Observable<Incident> {
    return this.http.get<ApiResponse<Incident>>(`${this.basePath}/${incidentId}`).pipe(
      map(response => response.data)
    );
  }

  resolve(incidentId: number): Observable<Incident> {
    return this.http.patch<ApiResponse<Incident>>(`${this.basePath}/${incidentId}/resolve`, {}).pipe(
      map(response => response.data)
    );
  }

  getAttachments(incidentId: number): Observable<IncidentAttachment[]> {
    return this.http.get<ApiResponse<IncidentAttachment[]>>(
      `${this.basePath}/${incidentId}/attachments`
    ).pipe(
      map(response => response.data)
    );
  }

  /**
   * Fetches an attachment's raw bytes as a Blob — a plain <img>/<audio> src
   * can't carry the Authorization header this endpoint requires, so the
   * caller turns this into an object URL (see incidents.ts).
   */
  getAttachmentBlob(incidentId: number, attachmentId: number): Observable<Blob> {
    return this.http.get(`${this.basePath}/${incidentId}/attachments/${attachmentId}`, {
      responseType: 'blob'
    });
  }
}
