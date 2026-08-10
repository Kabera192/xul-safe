export interface BusStop {
  id?: number;
  name: string;
  description?: string;
  latitude?: number;
  longitude?: number;
  address?: string;
  routeId?: number;
  order?: number;
  stopOrder?: number; // Backend field name
  createdAt?: string;
  updatedAt?: string;
}
