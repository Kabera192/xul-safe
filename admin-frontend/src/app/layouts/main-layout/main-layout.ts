import { ChangeDetectorRef, Component, OnDestroy, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { NotificationService } from '../../services/notification.service';
import { ThemeService } from '../../services/theme.service';
import { Notification, NotificationCategory, User } from '../../models';
import { Subscription, catchError, finalize, of, timeout } from 'rxjs';

interface HeaderNotificationViewModel {
  id: number;
  title: string;
  message: string;
  time: string;
}

/**
 * Categories actually triggered by a driver or parent doing something in
 * their app (marking attendance, reporting a problem, creating an absence,
 * starting/ending a journey) — as opposed to GENERAL (manually created,
 * not tied to any driver/parent action) or CHILD_ASSIGNED_TO_BUS (an admin
 * action). The header bell only shows the former.
 */
const DRIVER_PARENT_ACTION_CATEGORIES: NotificationCategory[] = [
  'ABSENCE_CREATED',
  'STUDENT_BOARDED_BUS',
  'STUDENT_EXITED_BUS',
  'BUS_PROBLEM_REPORTED',
  'BUS_REACHED_STOP',
  'JOURNEY_STARTED',
  'JOURNEY_ENDED',
  'INCIDENT_REPORTED',
  'ROUTE_REQUEST_SUBMITTED',
];

@Component({
  selector: 'app-main-layout',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive, RouterOutlet],
  templateUrl: './main-layout.html',
  styleUrl: './main-layout.scss',
})
export class MainLayout implements OnInit, OnDestroy {
  private authService = inject(AuthService);
  private notificationService = inject(NotificationService);
  private themeService = inject(ThemeService);
  private router = inject(Router);
  private cdr = inject(ChangeDetectorRef);
  private userSub?: Subscription;
  private notificationsSub?: Subscription;

  isSidebarCollapsed = false;
  currentUser: User | null = null;

  showNotifications = false;
  notificationsLoading = false;
  unreadCount = 0;
  notifications: HeaderNotificationViewModel[] = [];

  menuItems = [
    { label: 'Dashboard', icon: 'dashboard', route: '/dashboard' },
    { label: 'School buses', icon: 'bus', route: '/school-buses' },
    { label: 'All Students', icon: 'students', route: '/students' },
    { label: 'Trip attendance', icon: 'attendance', route: '/trip-attendance' },
    { label: 'Absences', icon: 'absences', route: '/absences' },
    { label: 'Routes & Stops', icon: 'routes', route: '/routes' },
    { label: 'Drivers', icon: 'conductors', route: '/drivers' },
    { label: 'User Requests', icon: 'requests', route: '/requests' },
    { label: 'Incidents', icon: 'incidents', route: '/incidents' },
  ];

  ngOnInit(): void {
    this.userSub = this.authService.currentUser$.subscribe(user => {
      this.currentUser = user;
      if (user?.id) {
        this.loadNotifications(user.id);
      } else {
        this.unreadCount = 0;
        this.notifications = [];
      }
      this.cdr.detectChanges();
    });
  }

  ngOnDestroy(): void {
    this.userSub?.unsubscribe();
    this.notificationsSub?.unsubscribe();
  }

  toggleNotifications(): void {
    this.showNotifications = !this.showNotifications;
    if (this.showNotifications && this.currentUser?.id) {
      this.loadNotifications(this.currentUser.id);
    }
  }

  closeNotifications(): void {
    this.showNotifications = false;
  }

  private loadNotifications(userId: number): void {
    // Cancel any request already in flight — otherwise re-opening the
    // dropdown while a slow request is still pending starts a second,
    // independent 4s timer instead of replacing the first one, and the
    // loading state can appear to hang well past 4s.
    this.notificationsSub?.unsubscribe();

    this.notificationsLoading = true;
    this.notificationsSub = this.notificationService.getUnreadForUser(userId).pipe(
      timeout(4000),
      catchError(() => of([] as Notification[])),
      finalize(() => {
        this.notificationsLoading = false;
        this.cdr.detectChanges();
      })
    ).subscribe((notifications) => {
      const relevant = notifications.filter((n) =>
        n.category ? DRIVER_PARENT_ACTION_CATEGORIES.includes(n.category) : false
      );
      this.notifications = relevant.map((n) => this.toViewModel(n));
      this.unreadCount = relevant.length;
      this.cdr.detectChanges();
    });
  }

  markNotificationRead(notif: HeaderNotificationViewModel): void {
    const userId = this.currentUser?.id;
    if (!userId) return;

    this.notifications = this.notifications.filter((n) => n.id !== notif.id);
    this.unreadCount = Math.max(0, this.unreadCount - 1);

    this.notificationService.markAsRead(notif.id, userId).pipe(
      catchError(() => of(void 0))
    ).subscribe();
  }

  markAllNotificationsRead(): void {
    const userId = this.currentUser?.id;
    if (!userId) return;

    this.notifications = [];
    this.unreadCount = 0;

    this.notificationService.markAllAsRead(userId).pipe(
      catchError(() => of(void 0))
    ).subscribe();
  }

  private toViewModel(notification: Notification): HeaderNotificationViewModel {
    return {
      id: notification.id || 0,
      title: notification.title,
      message: notification.message,
      time: this.formatTime(notification.createdAt)
    };
  }

  private formatTime(dateStr?: string): string {
    if (!dateStr) return 'Just now';
    const date = new Date(dateStr);
    const diffMs = Date.now() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins} min ago`;
    const diffHours = Math.floor(diffMins / 60);
    if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`;
    const diffDays = Math.floor(diffHours / 24);
    return `${diffDays} day${diffDays > 1 ? 's' : ''} ago`;
  }

  toggleSidebar(): void {
    this.isSidebarCollapsed = !this.isSidebarCollapsed;
  }

  get isDarkTheme(): boolean {
    return this.themeService.theme() === 'dark';
  }

  toggleTheme(): void {
    this.themeService.toggle();
    this.cdr.detectChanges();
  }

  get displayName(): string {
    if (!this.currentUser) {
      return 'User';
    }
    return `${this.currentUser.firstName} ${this.currentUser.lastName}`.trim();
  }

  get displayRole(): string {
    return this.currentUser?.role ?? 'User';
  }

  get initials(): string {
    if (!this.currentUser) {
      return 'U';
    }
    const first = this.currentUser.firstName?.charAt(0) ?? '';
    const last = this.currentUser.lastName?.charAt(0) ?? '';
    return (first + last).toUpperCase() || 'U';
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }
}
