export type BusStatus = 'ACTIVE' | 'INACTIVE' | 'MAINTENANCE';

export interface Bus {
  id?: number;
  plateNumber: string;
  model?: string;
  capacity?: number;
  status?: BusStatus;
  conductorId?: number | null;
  deviceId?: string | null;
  routeId?: number | null;
  photoUrl?: string | null;
  createdAt?: number;
}

/** Response from GET /buses/parent/{parentId}/assigned — includes bus, conductor, and route info. */
export interface BusParentAssignment {
  id?: number;
  plateNumber?: string;
  model?: string;
  capacity?: number;
  status?: string;
  routeId?: number;
  photoUrl?: string;
  conductorId?: number;
  conductorName?: string;
  conductorPhoneNumber?: string;
  conductorPhotoUrl?: string;
}
