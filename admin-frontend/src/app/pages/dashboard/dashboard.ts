import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { NotificationService } from '../../services/notification.service';
import { AuthService } from '../../services/auth.service';
import { BusService } from '../../services/bus.service';
import { ConductorService } from '../../services/conductor.service';
import { StudentService } from '../../services/student.service';
import { Bus, Child, Conductor, Notification } from '../../models';
import { catchError, finalize, forkJoin, of, timeout } from 'rxjs';

interface NotificationViewModel {
  id: number;
  type: string;
  title: string;
  message: string;
  time: string;
}

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './dashboard.html',
  styleUrl: './dashboard.scss',
})
export class Dashboard implements OnInit {
  private notificationService = inject(NotificationService);
  private authService = inject(AuthService);
  private busService = inject(BusService);
  private studentService = inject(StudentService);
  private conductorService = inject(ConductorService);
  private cdr = inject(ChangeDetectorRef);

  showEmergencyPanel = false;
  notificationsLoading = false;
  unreadCount = 0;
  statsLoading = false;
  statsError = '';

  stats = [
    { label: 'Available buses', value: '0', sublabel: 'buses', icon: 'bus' },
    { label: 'Students', value: '0', sublabel: 'students', icon: 'students' },
    { label: 'Conductors', value: '0', sublabel: 'staff', icon: 'present' },
    { label: 'Incidents', value: '0', sublabel: 'today', icon: 'incidents' },
    { label: 'Absent today', value: 'N/A', sublabel: 'students', icon: 'absent' },
  ];

  todayTrips = {
    scheduled: 0,
    inProgress: 0,
    completed: 0,
    studentsTransported: 0
  };

  schoolBuses: Array<{ id: string; route: string; status: 'active' | 'inactive' }> = [];

  busAttendance: Array<{
    date: string;
    bus: string;
    route: string;
    present: number | null;
    absent: number | null;
    status: string;
  }> = [];

  notifications: NotificationViewModel[] = [];

  ngOnInit(): void {
    this.loadDashboardData();
    this.loadNotifications();
  }

  loadDashboardData(): void {
    this.statsLoading = true;
    this.statsError = '';
    const fallbackTimer = window.setTimeout(() => {
      if (this.statsLoading) {
        this.statsLoading = false;
        this.statsError = 'Failed to load dashboard data. Please try again.';
        this.cdr.detectChanges();
      }
    }, 5000);

    forkJoin({
      buses: this.busService.getAll().pipe(catchError(() => of([] as Bus[]))),
      students: this.studentService.getAllAdmin().pipe(catchError(() => of([] as Child[]))),
      conductors: this.conductorService.getAll().pipe(catchError(() => of([] as Conductor[])))
    }).pipe(
      timeout(5000),
      finalize(() => {
        this.statsLoading = false;
        window.clearTimeout(fallbackTimer);
        this.cdr.detectChanges();
      })
    ).subscribe(({ buses, students, conductors }) => {
      const activeBuses = buses.filter((bus) => bus.status === 'ACTIVE').length;

      this.stats = [
        { label: 'Available buses', value: String(activeBuses), sublabel: 'buses', icon: 'bus' },
        { label: 'Students', value: String(students.length), sublabel: 'students', icon: 'students' },
        { label: 'Conductors', value: String(conductors.length), sublabel: 'staff', icon: 'present' },
        { label: 'Incidents', value: String(this.unreadCount), sublabel: 'today', icon: 'incidents' },
        { label: 'Absent today', value: 'N/A', sublabel: 'students', icon: 'absent' },
      ];

      this.schoolBuses = buses.slice(0, 3).map((bus) => ({
        id: bus.plateNumber,
        route: 'N/A',
        status: bus.status === 'ACTIVE' ? 'active' : 'inactive'
      }));

      // Update today's trips overview
      const activeBusCount = buses.filter(b => b.status === 'ACTIVE').length;
      const inactiveBusCount = buses.filter(b => b.status !== 'ACTIVE').length;
      this.todayTrips = {
        scheduled: buses.length * 2, // Assuming 2 trips per bus (pickup + dropoff)
        inProgress: activeBusCount,
        completed: inactiveBusCount,
        studentsTransported: students.length
      };

      const today = this.formatDate(new Date());
      this.busAttendance = buses.slice(0, 5).map((bus) => ({
        date: today,
        bus: bus.plateNumber,
        route: 'N/A',
        present: null,
        absent: null,
        status: bus.status === 'ACTIVE' ? 'In Progress' : 'Completed'
      }));

      this.cdr.detectChanges();
    });
  }

  loadNotifications(): void {
    const user = this.authService.getCurrentUser();
    if (!user?.id) {
      // Use mock data if no user logged in
      this.loadMockNotifications();
      return;
    }

    this.notificationsLoading = true;

    this.notificationService.getUnreadForUser(user.id).subscribe({
      next: (notifications) => {
        this.notifications = notifications.map(n => this.mapNotificationToViewModel(n));
        this.unreadCount = notifications.length;
        this.updateIncidentStat();
        this.notificationsLoading = false;
      },
      error: (error) => {
        console.error('Failed to load notifications:', error);
        this.loadMockNotifications();
        this.notificationsLoading = false;
      }
    });
  }

  private mapNotificationToViewModel(notification: Notification): NotificationViewModel {
    return {
      id: notification.id || 0,
      type: notification.type?.toLowerCase() || 'info',
      title: notification.title,
      message: notification.message,
      time: this.formatTime(notification.createdAt)
    };
  }

  private formatTime(dateStr?: string): string {
    if (!dateStr) return 'Just now';
    const date = new Date(dateStr);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins} min ago`;
    const diffHours = Math.floor(diffMins / 60);
    if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`;
    const diffDays = Math.floor(diffHours / 24);
    return `${diffDays} day${diffDays > 1 ? 's' : ''} ago`;
  }

  private loadMockNotifications(): void {
    this.notifications = [
      {
        id: 1,
        type: 'incident',
        title: 'Bus Incident',
        message: 'The bus with plate number KAE 132 B may got an accident on the way.',
        time: '2 min ago'
      }
    ];
    this.unreadCount = 1;
    this.updateIncidentStat();
  }

  private updateIncidentStat(): void {
    this.stats = this.stats.map((stat) => (
      stat.label === 'Incidents'
        ? { ...stat, value: String(this.unreadCount) }
        : stat
    ));
  }

  openEmergencyPanel(): void {
    this.showEmergencyPanel = true;
  }

  closeEmergencyPanel(): void {
    this.showEmergencyPanel = false;
  }

  private formatDate(date: Date): string {
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    return `${day}/${month}/${year}`;
  }
}
