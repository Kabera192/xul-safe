import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-forgot-password',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './forgot-password.html',
  styleUrl: './forgot-password.scss',
})
export class ForgotPassword {
  phoneNumber: string = '';
  loading: boolean = false;
  error: string = '';

  constructor(private router: Router, private authService: AuthService) {}

  onSubmit(): void {
    if (!this.phoneNumber.trim()) {
      this.error = 'Please enter your phone number.';
      return;
    }

    this.loading = true;
    this.error = '';

    this.authService.sendForgotPasswordOtp(this.phoneNumber.trim()).subscribe({
      next: () => {
        this.loading = false;
        this.router.navigate(['/otp-verification'], {
          state: { phoneNumber: this.phoneNumber.trim() }
        });
      },
      error: (err) => {
        this.loading = false;
        this.error = err?.error?.message ?? 'Failed to send code. Check your phone number.';
      }
    });
  }
}
