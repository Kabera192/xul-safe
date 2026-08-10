import { Component, ElementRef, QueryList, ViewChildren } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-otp-verification',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './otp-verification.html',
  styleUrl: './otp-verification.scss',
})
export class OtpVerification {
  @ViewChildren('otpInput') otpInputs!: QueryList<ElementRef>;

  otpValues: string[] = ['', '', '', '', '', ''];
  loading: boolean = false;
  resending: boolean = false;
  error: string = '';

  phoneNumber: string = '';

  constructor(private router: Router, private authService: AuthService) {
    this.phoneNumber = this.router.getCurrentNavigation()?.extras.state?.['phoneNumber']
      ?? (window.history.state?.phoneNumber ?? '');
  }

  onOtpInput(event: Event, index: number): void {
    const input = event.target as HTMLInputElement;
    const value = input.value;

    if (value.length === 1 && index < 5) {
      const inputs = this.otpInputs.toArray();
      inputs[index + 1].nativeElement.focus();
    }
  }

  onKeyDown(event: KeyboardEvent, index: number): void {
    if (event.key === 'Backspace' && !this.otpValues[index] && index > 0) {
      const inputs = this.otpInputs.toArray();
      inputs[index - 1].nativeElement.focus();
    }
  }

  onVerify(): void {
    const otp = this.otpValues.join('');
    if (otp.length < 6) {
      this.error = 'Please enter all 6 digits.';
      return;
    }

    this.loading = true;
    this.error = '';

    this.authService.verifyOtp(this.phoneNumber, otp).subscribe({
      next: () => {
        this.loading = false;
        this.router.navigate(['/new-password'], {
          state: { phoneNumber: this.phoneNumber, otp }
        });
      },
      error: (err) => {
        this.loading = false;
        this.error = err?.error?.message ?? 'Invalid or expired code. Please try again.';
      }
    });
  }

  resendCode(): void {
    if (this.resending) return;
    this.resending = true;
    this.error = '';
    this.otpValues = ['', '', '', '', '', ''];

    this.authService.sendForgotPasswordOtp(this.phoneNumber).subscribe({
      next: () => {
        this.resending = false;
      },
      error: (err) => {
        this.resending = false;
        this.error = err?.error?.message ?? 'Could not resend code. Please try again.';
      }
    });
  }
}
