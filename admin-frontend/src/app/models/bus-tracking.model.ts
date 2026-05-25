export type TripType = 'MORNING_PICKUP' | 'AFTERNOON_DROPOFF';
export type BusTrackingStatus = 'NOT_STARTED' | 'GOING_TO_SCHOOL' | 'AT_SCHOOL' | 'DROPPING_OFF_CHILDREN' | 'COMPLETED';

export interface BusTracking {
  id?: string;
  tripType: TripType;
  status: BusTrackingStatus;
  conductorId: number;
  busId: number;
  routeId?: number;
  currentLatitude?: number;
  currentLongitude?: number;
  speed?: number;
  lastUpdated?: string;
  startedAt?: string;
  endedAt?: string;
}

export interface StartJourneyRequest {
  tripType: TripType;
  conductorId: number;
  busId: number;
  routeId?: number;
  latitude?: number;
  longitude?: number;
}

export interface LocationUpdate {
  latitude: number;
  longitude: number;
}

export interface StatusUpdate {
  status: BusTrackingStatus;
}
