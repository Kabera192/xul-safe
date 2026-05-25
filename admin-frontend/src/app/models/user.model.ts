export interface User {
  id?: number;
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
  role?: string;
  roles?: string[];
  password?: string;
  photoUrl?: string;
  profileId?: number;
  createdAt?: string;
  updatedAt?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

/** Minimal user info embedded in the auth response from the backend. */
export interface AuthUserInfo {
  user_id: number;
  roles: string[];
}

/**
 * Shape returned directly by POST /auth/login and POST /auth/register.
 * NOT wrapped in ApiResponse — returned at the top level.
 * Field names match the backend Java field names (snake_case where applicable).
 */
export interface AuthResponse {
  token: string;
  token_expires_at?: string;
  refresh_token?: string;
  refresh_token_expires_at?: string;
  user: AuthUserInfo;
}

export interface PasswordUpdateRequest {
  currentPassword: string;
  newPassword: string;
}

/** Full profile returned by GET /profile/me and PATCH /profile/me. */
export interface ProfileResponse {
  userId: number;
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
  photoUrl?: string;
  roles: string[];
  profileId?: number;
}
