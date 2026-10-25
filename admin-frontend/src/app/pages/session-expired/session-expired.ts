import { Component, inject } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-session-expired',
  standalone: true,
  templateUrl: './session-expired.html',
  styleUrl: './session-expired.scss',
})
export class SessionExpired {
  private router = inject(Router);

  returnToLogin(): void {
    this.router.navigate(['/login']);
  }
}
