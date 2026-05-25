export type Gender = 'MALE' | 'FEMALE';

export interface Child {
  id?: string;
  fullName: string;
  birthDate?: string;
  gender?: Gender;
  grade?: string;
  parentId?: number;
  photoUrl?: string;
  busId?: number;
  routeId?: number;
  busStopId?: string;
  createdAt?: number;
  updatedAt?: string;
}

/**
 * Enriched child data returned by admin endpoint with related entity names.
 */
export interface ChildDetail {
  id?: string;
  fullName: string;
  birthDate?: string;
  gender?: Gender;
  grade?: string;
  photoUrl?: string;
  parentId?: number;
  busId?: number;
  busPlateNumber?: string;
  busDeviceId?: string;
  conductorId?: number;
  conductorName?: string;
  routeId?: number;
  routeName?: string;
  busStopId?: string;
  busStopName?: string;
  busStopLocation?: string;
  createdAt?: number;
}
