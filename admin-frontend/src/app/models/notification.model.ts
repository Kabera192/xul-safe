export type NotificationType = 'INFO' | 'WARNING' | 'ALERT' | 'INCIDENT';

export interface Notification {
  id?: number;
  title: string;
  message: string;
  type?: NotificationType;
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
