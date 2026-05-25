import { Component, OnInit, inject, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { NotificationService } from '../../services/notification.service';
import { AuthService } from '../../services/auth.service';
import { Notification, NotificationType, CreateNotificationRequest } from '../../models';
import { catchError, of, finalize } from 'rxjs';

interface IncidentItem {
  id?: number;
  title: string;
  message: string;
  time: string;
  isNew: boolean;
  type: string;
}

interface AnnouncementItem {
  id?: number;
  title: string;
  message: string;
  date: string;
  audience: string;
}

@Component({
  selector: 'app-incidents',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './incidents.html',
  styleUrl: './incidents.scss',
})
export class Incidents implements OnInit {
  private notificationService = inject(NotificationService);
  private authService = inject(AuthService);
  private cdr = inject(ChangeDetectorRef);

  activeTab: 'incidents' | 'announcements' = 'incidents';
  isLoading = false;
  isSaving = false;
  errorMessage = '';
  successMessage = '';

  // Create announcement modal
  showCreateModal = false;
  newTitle = '';
  newMessage = '';
  newType: NotificationType = 'INFO';

  // Detail side panel
  showDetailPanel = false;
  selectedItem: IncidentItem | null = null;

  incidentItems: IncidentItem[] = [];
  announcementItems: AnnouncementItem[] = [];

  readonly typeOptions: { value: NotificationType; label: string }[] = [
    { value: 'INFO', label: 'Info' },
    { value: 'WARNING', label: 'Warning' },
    { value: 'ALERT', label: 'Alert' },
    { value: 'INCIDENT', label: 'Incident' },
  ];

  ngOnInit(): void {
    this.loadNotifications();
  }

  loadNotifications(): void {
    const user = this.authService.getCurrentUser();
    if (!user?.id) {
      this.loadMockData();
      return;
    }
    this.isLoading = true;
    this.notificationService.getForUser(user.id).pipe(
      catchError(() => of([] as Notification[])),
      finalize(() => {
        this.isLoading = false;
        this.cdr.detectChanges();
      })
    ).subscribe((notifications) => {
      if (notifications.length === 0) {
        this.loadMockData();
        return;
      }
      this.incidentItems = notifications
        .filter(n => n.type === 'INCIDENT' || n.type === 'ALERT' || n.type === 'WARNING')
        .map(n => this.mapToIncident(n));
      this.announcementItems = notifications
        .filter(n => !n.type || n.type === 'INFO')
        .map(n => this.mapToAnnouncement(n));
      if (this.incidentItems.length === 0 && this.announcementItems.length === 0) {
        this.loadMockData();
      }
      this.cdr.detectChanges();
    });
  }

  private loadMockData(): void {
    this.incidentItems = [
      { title: 'Driving incident', message: 'The bus with plate number RAE 123 B had an accident on road. Emergency services have been notified.', time: 'Today at 18:30', isNew: true, type: 'INCIDENT' },
      { title: 'Driving incident', message: 'Bus KAE 456 C reported a collision near the school entrance. All students are safe.', time: 'Today at 16:00', isNew: true, type: 'INCIDENT' },
      { title: 'Route delay', message: 'Bus RAB 789 D is running 20 minutes late on Route A due to road construction.', time: 'May 5 at 13:30', isNew: false, type: 'WARNING' },
    ];
    this.announcementItems = [
      { title: 'Unavailable bus', message: 'Bus RAE 123B will be unavailable this Friday due to scheduled maintenance. Alternative transport is being arranged.', date: 'Today at 18:30', audience: 'All Parents' },
      { title: 'School day off', message: 'School is closed next Monday. No bus service will run. Students will resume on Tuesday.', date: '12-May-2025', audience: 'All Parents' },
      { title: 'Route change notice', message: 'Route A has been updated with a new bus stop near Main Street, effective from next week.', date: '7-May-2025', audience: 'Route A Parents' },
    ];
  }

  private mapToIncident(n: Notification): IncidentItem {
    return {
      id: n.id,
      title: n.title,
      message: n.message,
      time: this.formatTime(n.createdAt),
      isNew: !n.isRead,
      type: n.type || 'INFO',
    };
  }

  private mapToAnnouncement(n: Notification): AnnouncementItem {
    return {
      id: n.id,
      title: n.title,
      message: n.message,
      date: this.formatDate(n.createdAt),
      audience: 'All Parents',
    };
  }

  private formatTime(dateStr?: string): string {
    if (!dateStr) return 'Just now';
    const date = new Date(dateStr);
    const now = new Date();
    const diffMins = Math.floor((now.getTime() - date.getTime()) / 60000);
    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins} min ago`;
    const diffHours = Math.floor(diffMins / 60);
    if (diffHours < 24) return `${diffHours}h ago`;
    return date.toLocaleDateString('en-GB', { day: '2-digit', month: 'short' });
  }

  private formatDate(dateStr?: string): string {
    if (!dateStr) return 'N/A';
    return new Date(dateStr).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
  }

  get newIncidentCount(): number {
    return this.incidentItems.filter(i => i.isNew).length;
  }

  openCreateModal(): void {
    this.showCreateModal = true;
    this.newTitle = '';
    this.newMessage = '';
    this.newType = 'INFO';
    this.errorMessage = '';
  }

  closeCreateModal(): void {
    this.showCreateModal = false;
  }

  createAnnouncement(): void {
    if (!this.newTitle.trim() || !this.newMessage.trim()) return;
    this.isSaving = true;
    const user = this.authService.getCurrentUser();
    const request: CreateNotificationRequest = {
      title: this.newTitle.trim(),
      message: this.newMessage.trim(),
      type: this.newType,
      createdBy: user?.id,
    };
    this.notificationService.create(request).pipe(
      finalize(() => {
        this.isSaving = false;
        this.cdr.detectChanges();
      })
    ).subscribe({
      next: (notification) => {
        this.announcementItems = [{
          id: notification.id,
          title: notification.title,
          message: notification.message,
          date: 'Just now',
          audience: 'All users',
        }, ...this.announcementItems];
        this.closeCreateModal();
        this.successMessage = 'Announcement created successfully!';
        setTimeout(() => { this.successMessage = ''; this.cdr.detectChanges(); }, 3000);
        this.cdr.detectChanges();
      },
      error: () => {
        this.errorMessage = 'Failed to create announcement. Please try again.';
        this.cdr.detectChanges();
      }
    });
  }

  openDetail(item: IncidentItem): void {
    this.selectedItem = item;
    this.showDetailPanel = true;
  }

  closeDetail(): void {
    this.showDetailPanel = false;
    this.selectedItem = null;
  }
}
