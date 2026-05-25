import { Component, ElementRef, QueryList, ViewChildren } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';

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

  constructor(private router: Router) {}

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
    console.log('Verify OTP:', otp);
    this.router.navigate(['/new-password']);
  }

  resendCode(): void {
    console.log('Resend code');
    // TODO: Implement resend logic
  }
}
