export type TripType = 'MORNING_PICKUP' | 'AFTERNOON_DROPOFF';
export type BusTrackingStatus = 'NOT_IN_ROUTE' | 'PICKING_UP_CHILDREN' | 'GOING_TO_SCHOOL' | 'AT_SCHOOL' | 'DROPPING_OFF_CHILDREN';

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

export type TodayTripStatus = 'SCHEDULED' | 'IN_PROGRESS' | 'COMPLETED';

export interface BusTripStatusToday {
  busId: number;
  status: TodayTripStatus;
}

export interface BusAttendanceToday {
  busId: number;
  plateNumber: string;
  routeName: string | null;
  date: string;
  /** Null until the trip starts — no one could truthfully be marked present/absent yet. */
  present: number | null;
  absent: number | null;
  tripStatus: TodayTripStatus;
}
