import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ApiResponse, Notification, CreateNotificationRequest } from '../models';

@Injectable({
  providedIn: 'root'
})
export class NotificationService {
  private http = inject(HttpClient);
  private readonly basePath = '/notifications';

  create(request: CreateNotificationRequest): Observable<Notification> {
    return this.http.post<ApiResponse<Notification>>(`${this.basePath}`, request).pipe(
      map(response => response.data)
    );
  }

  getForUser(userId: number): Observable<Notification[]> {
    return this.http.get<ApiResponse<Notification[]>>(`${this.basePath}/user/${userId}`).pipe(
      map(response => response.data)
    );
  }

  getUnreadForUser(userId: number): Observable<Notification[]> {
    return this.http.get<ApiResponse<Notification[]>>(`${this.basePath}/user/${userId}/unread`).pipe(
      map(response => response.data)
    );
  }

  getUnreadCount(userId: number): Observable<number> {
    return this.http.get<ApiResponse<number>>(`${this.basePath}/user/${userId}/unread/count`).pipe(
      map(response => response.data)
    );
  }

  markAsRead(notificationId: number, userId: number): Observable<void> {
    return this.http.put<ApiResponse<void>>(`${this.basePath}/${notificationId}/read`, { userId }).pipe(
      map(() => void 0)
    );
  }

  markAllAsRead(userId: number): Observable<void> {
    return this.http.put<ApiResponse<void>>(`${this.basePath}/user/${userId}/read-all`, {}).pipe(
      map(() => void 0)
    );
  }

  delete(notificationId: number): Observable<void> {
    return this.http.delete<ApiResponse<void>>(`${this.basePath}/${notificationId}`).pipe(
      map(() => void 0)
    );
  }
}
