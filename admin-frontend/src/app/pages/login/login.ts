import { ChangeDetectorRef, Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { finalize, timeout } from 'rxjs';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './login.html',
  styleUrl: './login.scss',
})
export class Login {
  private router = inject(Router);
  private authService = inject(AuthService);
  private cdr = inject(ChangeDetectorRef);

  email = '';
  password = '';
  showPassword = false;
  isLoading = false;
  errorMessage = '';

  togglePassword(): void {
    this.showPassword = !this.showPassword;
  }

  onSubmit(): void {
    if (!this.email || !this.password) {
      this.errorMessage = 'Please enter email and password';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';
    const fallbackTimer = window.setTimeout(() => {
      if (this.isLoading) {
        this.isLoading = false;
        this.errorMessage = 'Invalid email or password.';
        this.cdr.detectChanges();
      }
    }, 2000);

    this.authService.login({ email: this.email, password: this.password }).pipe(
      timeout(2000),
      finalize(() => {
        this.isLoading = false;
        window.clearTimeout(fallbackTimer);
        this.cdr.detectChanges();
      })
    ).subscribe({
      next: () => {
        this.router.navigate(['/dashboard']);
      },
      error: (error) => {
        if (error?.name === 'TimeoutError') {
          this.errorMessage = 'Login timed out. Please try again.';
          return;
        }

        if (error?.message === 'Bad request') {
          this.errorMessage = 'Invalid email or password.';
          return;
        }

        this.errorMessage = error?.message || 'Login failed. Please try again.';
      }
    });
  }
}
