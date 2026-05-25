export type JourneyType = 'PICKUP' | 'DROPOFF';
export type JourneyStatus = 'IN_PROGRESS' | 'COMPLETED';
export type AttendanceMark = 'present' | 'absent';

export interface Journey {
  id?: number;
  childId: string;
  childName?: string;
  routeName?: string;
  routeId?: number;
  journeyType: JourneyType;
  status: JourneyStatus;
  date: string;
  startTime?: string;
  endTime?: string;
  startLocation?: string;
  endLocation?: string;
  createdAt?: number;
}

export interface JourneySummary {
  journeys: Journey[];
  monthlyCount: number;
}

export interface JourneyRequest {
  childIds: string[];
}

export interface WeeklyAttendance {
  childId: string;
  childName?: string;
  routeName?: string;
  busPlateNumber?: string;
  mon: AttendanceMark[];
  tue: AttendanceMark[];
  wed: AttendanceMark[];
  thu: AttendanceMark[];
  fri: AttendanceMark[];
}
