import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-new-password',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './new-password.html',
  styleUrl: './new-password.scss',
})
export class NewPassword {
  password: string = '';
  confirmPassword: string = '';
  showPassword: boolean = false;
  showConfirmPassword: boolean = false;
  showSuccessPopup: boolean = false;

  loading: boolean = false;
  error: string = '';

  phoneNumber: string = '';
  otp: string = '';

  constructor(private router: Router, private authService: AuthService) {
    const state = this.router.getCurrentNavigation()?.extras.state ?? window.history.state;
    this.phoneNumber = state?.['phoneNumber'] ?? '';
    this.otp = state?.['otp'] ?? '';
  }

  togglePassword(): void {
    this.showPassword = !this.showPassword;
  }

  toggleConfirmPassword(): void {
    this.showConfirmPassword = !this.showConfirmPassword;
  }

  onConfirm(): void {
    this.error = '';

    if (!this.password) {
      this.error = 'Please enter a new password.';
      return;
    }
    if (this.password.length < 8) {
      this.error = 'Password must be at least 8 characters.';
      return;
    }
    if (!/[A-Z]/.test(this.password)) {
      this.error = 'Password must contain an uppercase letter.';
      return;
    }
    if (!/[a-z]/.test(this.password)) {
      this.error = 'Password must contain a lowercase letter.';
      return;
    }
    if (!/[0-9]/.test(this.password)) {
      this.error = 'Password must contain a number.';
      return;
    }
    if (this.password !== this.confirmPassword) {
      this.error = 'Passwords do not match.';
      return;
    }

    this.loading = true;

    this.authService.resetPassword(this.phoneNumber, this.otp, this.password).subscribe({
      next: () => {
        this.loading = false;
        this.showSuccessPopup = true;
      },
      error: (err) => {
        this.loading = false;
        this.error = err?.error?.message ?? 'Failed to reset password. Please try again.';
      }
    });
  }

  onGotIt(): void {
    this.showSuccessPopup = false;
    this.router.navigate(['/login']);
  }
}
