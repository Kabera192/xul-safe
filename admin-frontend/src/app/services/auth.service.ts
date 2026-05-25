import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, BehaviorSubject, map, tap, switchMap } from 'rxjs';
import { ApiResponse, User, LoginRequest, AuthResponse, ProfileResponse } from '../models';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private http = inject(HttpClient);
  private readonly basePath = '/auth';
  private readonly profilePath = '/profile';

  private currentUserSubject = new BehaviorSubject<User | null>(this.getStoredUser());
  readonly currentUser$ = this.currentUserSubject.asObservable();

  login(credentials: LoginRequest): Observable<AuthResponse> {
    // Backend returns AuthResponse directly (not wrapped in ApiResponse)
    return this.http.post<AuthResponse>(`${this.basePath}/login`, credentials).pipe(
      tap(authResponse => {
        localStorage.setItem('token', authResponse.token);
        if (authResponse.refresh_token) {
          localStorage.setItem('refreshToken', authResponse.refresh_token);
        }
      }),
      switchMap(authResponse =>
        // Fetch full profile now that token is stored
        // ProfileController returns ProfileResponse directly (not wrapped in ApiResponse)
        this.http.get<ProfileResponse>(`${this.profilePath}/me`).pipe(
          tap(profile => this.setCurrentUserFromProfile(profile)),
          map(() => authResponse)
        )
      )
    );
  }

  register(user: User): Observable<AuthResponse> {
    // Backend returns AuthResponse directly (not wrapped in ApiResponse)
    return this.http.post<AuthResponse>(`${this.basePath}/register`, user).pipe(
      tap(authResponse => {
        localStorage.setItem('token', authResponse.token);
        if (authResponse.refresh_token) {
          localStorage.setItem('refreshToken', authResponse.refresh_token);
        }
      }),
      switchMap(authResponse =>
        this.http.get<ProfileResponse>(`${this.profilePath}/me`).pipe(
          tap(profile => this.setCurrentUserFromProfile(profile)),
          map(() => authResponse)
        )
      )
    );
  }

  refreshAccessToken(): Observable<AuthResponse> {
    const refreshToken = localStorage.getItem('refreshToken');
    return this.http.post<AuthResponse>(`${this.basePath}/refresh`, { refresh_token: refreshToken }).pipe(
      tap(authResponse => {
        localStorage.setItem('token', authResponse.token);
        if (authResponse.refresh_token) {
          localStorage.setItem('refreshToken', authResponse.refresh_token);
        }
      })
    );
  }

  checkEmailExists(email: string): Observable<boolean> {
    return this.http.get<ApiResponse<boolean>>(`${this.basePath}/check-email`, {
      params: { email }
    }).pipe(map(response => response.data));
  }

  updatePassword(userId: number, currentPassword: string, newPassword: string): Observable<void> {
    return this.http.put<ApiResponse<void>>(`${this.basePath}/${userId}/password`, {
      currentPassword,
      newPassword
    }).pipe(map(() => void 0));
  }

  uploadProfilePhoto(userId: number, file: File): Observable<string> {
    const formData = new FormData();
    formData.append('file', file);
    return this.http.post<ApiResponse<string>>(`${this.basePath}/${userId}/photo`, formData).pipe(
      map(response => response.data)
    );
  }

  logout(): void {
    this.setCurrentUser(null);
    localStorage.removeItem('user');
    localStorage.removeItem('token');
    localStorage.removeItem('refreshToken');
  }

  getCurrentUser(): User | null {
    return this.currentUserSubject.value;
  }

  isLoggedIn(): boolean {
    return !!localStorage.getItem('token');
  }

  setCurrentUser(user: User | null): void {
    const normalized = user ? { ...user, photoUrl: this.normalizePhotoUrl(user.photoUrl) } : null;
    if (normalized) {
      localStorage.setItem('user', JSON.stringify(normalized));
    } else {
      localStorage.removeItem('user');
    }
    this.currentUserSubject.next(normalized);
  }

  private setCurrentUserFromProfile(profile: ProfileResponse): void {
    this.setCurrentUser({
      id: profile.userId,
      firstName: profile.firstName,
      lastName: profile.lastName,
      email: profile.email,
      phoneNumber: profile.phoneNumber,
      photoUrl: profile.photoUrl,
      roles: profile.roles,
      profileId: profile.profileId,
    });
  }

  private getStoredUser(): User | null {
    const stored = localStorage.getItem('user');
    const parsed = stored ? JSON.parse(stored) as User : null;
    if (!parsed) {
      return null;
    }
    return { ...parsed, photoUrl: this.normalizePhotoUrl(parsed.photoUrl) };
  }

  private normalizePhotoUrl(photoUrl?: string): string | undefined {
    if (!photoUrl) {
      return photoUrl;
    }
    if (photoUrl.startsWith('http')) {
      return photoUrl;
    }
    const base = environment.apiUrl.replace(/\/api\/v1\/?$/, '');
    return `${base}${photoUrl}`;
  }
}
