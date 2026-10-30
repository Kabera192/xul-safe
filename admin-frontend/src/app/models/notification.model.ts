export type NotificationType = 'INFO' | 'WARNING' | 'ALERT' | 'INCIDENT';

/** Mirrors the backend's NotificationCategory enum. */
export type NotificationCategory =
  | 'GENERAL'
  | 'ABSENCE_CREATED'
  | 'CHILD_ASSIGNED_TO_BUS'
  | 'STUDENT_BOARDED_BUS'
  | 'STUDENT_EXITED_BUS'
  | 'BUS_PROBLEM_REPORTED'
  | 'BUS_REACHED_STOP'
  | 'JOURNEY_STARTED'
  | 'JOURNEY_ENDED'
  | 'INCIDENT_REPORTED'
  | 'PARENT_REGISTERED'
  | 'STUDENT_ADDED'
  | 'BUS_CAPACITY_EXCEEDED'
  | 'ABSENCE_REPORTED_BY_PARENT';

export interface Notification {
  id?: number;
  title: string;
  message: string;
  type?: NotificationType;
  category?: NotificationCategory;
  createdBy?: number;
  isRead?: boolean;
  createdAt?: string;
}

export interface CreateNotificationRequest {
  title: string;
  message: string;
  type?: NotificationType;
  createdBy?: number;
  userIds?: number[];
}

export interface MarkReadRequest {
  userId: number;
}
