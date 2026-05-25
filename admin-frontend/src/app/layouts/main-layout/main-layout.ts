import { Component, OnDestroy, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { User } from '../../models';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-main-layout',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive, RouterOutlet],
  templateUrl: './main-layout.html',
  styleUrl: './main-layout.scss',
})
export class MainLayout implements OnInit, OnDestroy {
  private authService = inject(AuthService);
  private router = inject(Router);
  private userSub?: Subscription;

  isSidebarCollapsed = false;
  currentUser: User | null = null;

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
    });
  }

  ngOnDestroy(): void {
    this.userSub?.unsubscribe();
  }

  toggleSidebar(): void {
    this.isSidebarCollapsed = !this.isSidebarCollapsed;
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
