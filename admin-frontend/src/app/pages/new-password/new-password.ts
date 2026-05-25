import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';

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

  constructor(private router: Router) {}

  togglePassword(): void {
    this.showPassword = !this.showPassword;
  }

  toggleConfirmPassword(): void {
    this.showConfirmPassword = !this.showConfirmPassword;
  }

  onConfirm(): void {
    console.log('Password updated');
    this.showSuccessPopup = true;
  }

  onGotIt(): void {
    this.showSuccessPopup = false;
    this.router.navigate(['/login']);
  }
}
