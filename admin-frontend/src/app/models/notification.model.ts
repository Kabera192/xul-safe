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
  | 'ABSENCE_REPORTED_BY_PARENT'
  | 'ROUTE_REQUEST_SUBMITTED'
  | 'ROUTE_REQUEST_APPROVED'
  | 'ROUTE_REQUEST_REJECTED';

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

/** Mirrors the backend's NotificationWithStatusDto — a notification plus
 *  the calling user's own recipient status, since Notification itself has
 *  no per-recipient read state. */
export interface NotificationWithStatus {
  notificationId: number;
  title: string;
  message: string;
  type?: NotificationType;
  category?: NotificationCategory;
  params?: Record<string, string>;
  createdBy?: number;
  recipientUserId: number;
  status: 'PENDING' | 'SENT' | 'READ';
  sentAt?: number;
  readAt?: number;
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
