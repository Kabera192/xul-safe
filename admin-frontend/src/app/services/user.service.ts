import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiResponse, User } from '../models';

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private http = inject(HttpClient);
  private readonly basePath = '/users';

  getProfile(userId: number): Observable<User> {
    return this.http.get<ApiResponse<User>>(`${this.basePath}/${userId}`).pipe(
      map(response => response.data)
    );
  }

  updateProfile(userId: number, user: Partial<User>): Observable<User> {
    return this.http.put<ApiResponse<User>>(`${this.basePath}/${userId}`, user).pipe(
      map(response => response.data)
    );
  }
}
