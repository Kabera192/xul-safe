export interface Route {
  id?: number;
  name: string;
  description?: string;
  startLocation?: string;
  endLocation?: string;
  createdAt?: number;
}

export interface ChildRoute {
  routeId: number;
  routeName: string;
  busStopId: string;
  busStopName: string;
  busId?: number;
  busPlate?: string;
}

/** Extended route details with all selectable bus stops. Returned by GET /routes/child/{childId}/details. */
export interface ChildRouteDetails extends ChildRoute {
  stops?: Array<{
    id: number;
    locationName: string;
    locationLat?: number;
    locationLong?: number;
    orderIndex?: number;
  }>;
}

export type RouteRequestStatus = 'PENDING' | 'APPROVED' | 'REJECTED';

export interface RouteRequest {
  id?: number;
  parentId: number;
  childId: string;
  latitude: number;
  longitude: number;
  address?: string;
  description?: string;
  status?: RouteRequestStatus;
  createdAt?: number;
  updatedAt?: number;
}

export interface SelectBusStopRequest {
  parentId: string;
  childId: string;
  busStopId: string;
}
