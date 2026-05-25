import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { UserService } from '../../services/user.service';
import { User } from '../../models';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './profile.html',
  styleUrl: './profile.scss',
})
export class ProfilePage implements OnInit {
  private authService = inject(AuthService);
  private userService = inject(UserService);
  private router = inject(Router);

  currentUser: User | null = null;
  isSaving = false;
  errorMessage = '';
  successMessage = '';

  firstName = '';
  lastName = '';
  email = '';
  phoneNumber = '';
  photoPreview = '';

  ngOnInit(): void {
    this.currentUser = this.authService.getCurrentUser();
    if (!this.currentUser?.id) {
      this.router.navigate(['/login']);
      return;
    }
    this.firstName = this.currentUser.firstName ?? '';
    this.lastName = this.currentUser.lastName ?? '';
    this.email = this.currentUser.email ?? '';
    this.phoneNumber = this.currentUser.phoneNumber ?? '';
    this.photoPreview = this.currentUser.photoUrl ?? '';
  }

  onPhotoSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (!input.files || input.files.length === 0 || !this.currentUser?.id) {
      return;
    }
    const file = input.files[0];
    const reader = new FileReader();
    reader.onload = () => {
      this.photoPreview = String(reader.result || '');
    };
    reader.readAsDataURL(file);

    this.authService.uploadProfilePhoto(this.currentUser.id, file).subscribe({
      next: (photoUrl) => {
        this.updateStoredUser({ photoUrl: this.normalizePhotoUrl(photoUrl) });
      },
      error: (error) => {
        this.errorMessage = error.message || 'Failed to upload photo.';
      }
    });
  }

  saveProfile(): void {
    if (!this.currentUser?.id) {
      return;
    }
    this.isSaving = true;
    this.errorMessage = '';
    this.successMessage = '';

    this.userService.updateProfile(this.currentUser.id, {
      firstName: this.firstName,
      lastName: this.lastName,
      phoneNumber: this.phoneNumber
    }).subscribe({
      next: (user) => {
        this.updateStoredUser(user);
        this.successMessage = 'Profile updated successfully.';
        this.isSaving = false;
        this.router.navigate(['/dashboard']);
      },
      error: (error) => {
        this.errorMessage = error.message || 'Failed to update profile.';
        this.isSaving = false;
      }
    });
  }

  private updateStoredUser(update: Partial<User>): void {
    if (!this.currentUser) {
      return;
    }
    const nextUser = { ...this.currentUser, ...update };
    this.currentUser = nextUser;
    this.authService.setCurrentUser(nextUser);
  }

  private normalizePhotoUrl(photoUrl: string): string {
    if (!photoUrl) {
      return photoUrl;
    }
    if (photoUrl.startsWith('http')) {
      return photoUrl;
    }
    const base = environment.apiUrl.replace(/\/api\/v1\/?$/, '');
    return `${base}${photoUrl}`;
  }
}
