export type AbsenceType = 'MORNING' | 'EVENING' | 'MULTIPLE_DAYS';
export type AbsenceStatus = 'ACTIVE' | 'COMPLETED';

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
