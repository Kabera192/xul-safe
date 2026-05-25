import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiResponse, ProfileResponse } from '../models';

export interface UpdateProfileRequest {
  firstName?: string;
  lastName?: string;
  phoneNumber?: string;
  email?: string;
}

@Injectable({
  providedIn: 'root'
})
export class ProfileService {
  private http = inject(HttpClient);
  private readonly basePath = '/profile';

  /** GET /profile/me — returns the authenticated user's full profile. */
  getMyProfile(): Observable<ProfileResponse> {
    return this.http.get<ProfileResponse>(`${this.basePath}/me`);
  }

  /** PATCH /profile/me — updates name/phone/email for the authenticated user. */
  updateMyProfile(update: UpdateProfileRequest): Observable<ProfileResponse> {
    return this.http.patch<ProfileResponse>(`${this.basePath}/me`, update);
  }

  /** PATCH /profile/me/photo — uploads a profile photo for the authenticated user. */
  uploadMyPhoto(file: File): Observable<string> {
    const formData = new FormData();
    formData.append('file', file);
    return this.http.patch<ApiResponse<string>>(`${this.basePath}/me/photo`, formData).pipe(
      map(response => response.data)
    );
  }
}
