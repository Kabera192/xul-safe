export type AbsenceType = 'MORNING' | 'AFTERNOON' | 'FULL_DAY';
export type AbsenceStatus = 'ACTIVE' | 'COMPLETED' | 'CANCELLED';

export interface Absence {
  id?: number;
  childId: string;
  childName?: string; // enriched by backend
  parentId: number;
  absenceType: AbsenceType;
  startDate: string;
  endDate: string;
  status?: AbsenceStatus;
  reason?: string;
  createdAt?: number;
  updatedAt?: number;
}
