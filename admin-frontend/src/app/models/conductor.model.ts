export type ConductorStatus = 'ACTIVE' | 'INACTIVE';

export interface Conductor {
  id?: number;
  /** Linked user account id — present for drivers that have a login. */
  userId?: number | null;
  /** User account fields — required when creating via /api/v1/drivers. */
  firstName?: string | null;
  lastName?: string | null;
  /** Write-only — only sent on create/update, never returned. */
  password?: string | null;
  fullName: string;
  phoneNumber: string;
  email?: string | null;
  photoUrl?: string | null;
  gender?: string | null;
  age?: number | null;
  driverId?: string | null;
  licenceNumber?: string | null;
  licenceType?: string | null;
  licenceExpiry?: string | null;
  experience?: string | null;
  status?: ConductorStatus;
  createdAt?: number;
}
