import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError, map, of, tap } from 'rxjs';

export interface PlaceSuggestion {
  name: string;
  lat: number;
  lng: number;
}

/**
 * Reverse geocoding via OpenStreetMap's Nominatim — free, no API key,
 * matching the lookup the mobile app already uses for its own location
 * picker. Used so picking a point on the admin map can fill in a
 * human-readable address instead of leaving it to be typed by hand.
 */
@Injectable({ providedIn: 'root' })
export class GeocodingService {
  private http = inject(HttpClient);
  private placeCache = new Map<string, PlaceSuggestion[]>();

  reverseGeocode(lat: number, lng: number): Observable<string | null> {
    const url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&addressdetails=1`;

    return this.http.get<{ display_name?: string }>(url).pipe(
      map((res) => res?.display_name ?? null),
      catchError(() => of(null))
    );
  }

  /**
   * Forward place-name search — same Nominatim endpoint and params
   * (countrycodes=rw, limit=5) the driver app uses for its bus-stop
   * location search, so admin location fields offer the same suggestions.
   * Results are cached per query so retyping/backspacing over something
   * already searched resolves instantly instead of re-hitting the network.
   */
  searchPlaces(query: string): Observable<PlaceSuggestion[]> {
    const key = query.trim().toLowerCase();
    const cached = this.placeCache.get(key);
    if (cached) {
      return of(cached);
    }

    const url = `https://nominatim.openstreetmap.org/search?format=json&limit=5&countrycodes=rw&q=${encodeURIComponent(query)}`;

    return this.http.get<Array<{ display_name?: string; lat?: string; lon?: string }>>(url).pipe(
      map((results) =>
        (results ?? [])
          .map((r) => ({
            name: r.display_name ?? '',
            lat: parseFloat(r.lat ?? ''),
            lng: parseFloat(r.lon ?? ''),
          }))
          .filter((place) => place.name.length > 0 && Number.isFinite(place.lat) && Number.isFinite(place.lng))
      ),
      tap((places) => this.placeCache.set(key, places)),
      catchError(() => of([]))
    );
  }
}
