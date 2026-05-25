/** Bus assigned to the authenticated driver. Returned by GET /me/bus. */
export interface DriverBus {
  id: number;
  plateNumber: string;
  model?: string;
  capacity?: number;
  status?: string;
  routeId?: number;
  photoUrl?: string;
}

/** Route of the driver's bus. Returned by GET /me/bus/route. */
export interface DriverRoute {
  id: number;
  name: string;
  description?: string;
  startLocation?: string;
  endLocation?: string;
}

/** A stop on the driver's route. Returned by GET /me/bus/route/stops. */
export interface DriverStop {
  id: number;
  routeId: number;
  locationName: string;
  locationLat: number;
  locationLong: number;
  orderIndex?: number;
}

export interface CreateStopRequest {
  name: string;
  latitude: number;
  longitude: number;
  orderIndex?: number;
}

export interface UpdateStopRequest {
  name?: string;
  latitude?: number;
  longitude?: number;
  orderIndex?: number;
}

/** Summary of a child on the driver's bus. Returned by GET /me/bus/children. */
export interface DriverChild {
  id: string;
  fullName: string;
  grade?: string;
  gender?: string;
  photoUrl?: string;
  pickupStopId?: number;
  dropoffStopId?: number;
}

export interface AssignChildrenToStopRequest {
  childIds: string[];
  stopType?: 'PICKUP' | 'DROPOFF';
}
