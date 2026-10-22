export type IncidentType =
  | 'ACCIDENT'
  | 'VEHICLE_BREAKDOWN'
  | 'DELAY'
  | 'ROAD_OBSTRUCTION'
  | 'MEDICAL'
  | 'CHILD_BEHAVIOR'
  | 'OTHER';

export type IncidentStatus = 'ACTIVE' | 'RESOLVED';

export type JourneyImpact = 'NONE' | 'DELAYED' | 'STOPPED';

export type IncidentAttachmentType = 'IMAGE' | 'AUDIO';

export interface Incident {
  id: number;
  type: IncidentType;
  description: string;
  status: IncidentStatus;
  journeyImpact: JourneyImpact;
  createdBy?: number;
  createdAt?: number;
  resolvedBy?: number;
  resolvedAt?: number;
  affectedBusIds?: number[];
  affectedChildIds?: string[];
  relatedTrackingIds?: string[];
}

export interface IncidentAttachment {
  id: number;
  type: IncidentAttachmentType;
  createdAt?: number;
}
