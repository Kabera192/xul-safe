import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { NotificationService } from '../../services/notification.service';
import { Notification } from '../../models';
import { catchError, finalize, of } from 'rxjs';

interface NotificationRow {
  id: number;
  title: string;
  message: string;
  time: string;
  isRead: boolean;
  createdAtValue: number;
}

@Component({
  selector: 'app-notifications',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './notifications.html',
  styleUrl: './notifications.scss',
})
export class NotificationsPage implements OnInit {
  private authService = inject(AuthService);
  private notificationService = inject(NotificationService);
  private cdr = inject(ChangeDetectorRef);

  isLoading = false;
  errorMessage = '';
  searchTerm = '';
  notificationRows: NotificationRow[] = [];

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    const userId = this.authService.getCurrentUser()?.id;
    if (!userId) {
      this.errorMessage = 'You must be logged in to view notifications.';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    this.notificationService.getForUser(userId).pipe(
      catchError(() => {
        this.errorMessage = 'Failed to load notifications. Please try again.';
        return of([] as Notification[]);
      }),
      finalize(() => {
        this.isLoading = false;
        this.cdr.detectChanges();
      })
    ).subscribe((notifications) => {
      this.notificationRows = notifications
        .map((n) => this.toRow(n))
        .sort((a, b) => b.createdAtValue - a.createdAtValue);
    });
  }

  get filteredRows(): NotificationRow[] {
    const term = this.searchTerm.trim().toLowerCase();
    if (!term) {
      return this.notificationRows;
    }
    return this.notificationRows.filter((row) =>
      row.title.toLowerCase().includes(term) || row.message.toLowerCase().includes(term)
    );
  }

  get unreadCount(): number {
    return this.notificationRows.filter((row) => !row.isRead).length;
  }

  markRead(row: NotificationRow): void {
    if (row.isRead) return;
    const userId = this.authService.getCurrentUser()?.id;
    if (!userId) return;

    row.isRead = true;
    this.notificationService.markAsRead(row.id, userId).pipe(
      catchError(() => of(void 0))
    ).subscribe();
  }

  markAllRead(): void {
    const userId = this.authService.getCurrentUser()?.id;
    if (!userId) return;

    this.notificationRows.forEach((row) => (row.isRead = true));
    this.notificationService.markAllAsRead(userId).pipe(
      catchError(() => of(void 0))
    ).subscribe();
  }

  private toRow(notification: Notification): NotificationRow {
    const createdAtValue = notification.createdAt ? new Date(notification.createdAt).getTime() : 0;
    return {
      id: notification.id || 0,
      title: notification.title,
      message: notification.message,
      time: notification.createdAt ? new Date(notification.createdAt).toLocaleString('en-GB') : 'N/A',
      isRead: notification.isRead ?? false,
      createdAtValue,
    };
  }
}
