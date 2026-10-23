import { Injectable } from '@angular/core';

declare const google: any;

/**
 * Loads the Google Maps JS SDK exactly once per page, however many
 * map-picker instances ask for it. Extracted from request-details.ts,
 * which previously duplicated this loading logic for its own single map.
 */
@Injectable({ providedIn: 'root' })
export class GoogleMapsLoaderService {
  private loader?: Promise<void>;

  load(): Promise<void> {
    if (typeof google !== 'undefined' && google.maps) {
      return Promise.resolve();
    }

    if (this.loader) {
      return this.loader;
    }

    this.loader = new Promise((resolve, reject) => {
      const scriptId = 'google-maps-sdk';
      const existing = document.getElementById(scriptId) as HTMLScriptElement | null;

      if (existing) {
        if (typeof google !== 'undefined' && google.maps) {
          resolve();
          return;
        }

        const onLoad = () => {
          existing.removeEventListener('error', onError);
          if (typeof google !== 'undefined' && google.maps) {
            resolve();
            return;
          }
          reject(new Error('Google Maps loaded without maps API'));
        };
        const onError = () => {
          existing.removeEventListener('load', onLoad);
          reject(new Error('Failed to load Google Maps'));
        };

        existing.addEventListener('load', onLoad, { once: true });
        existing.addEventListener('error', onError, { once: true });
        return;
      }

      const script = document.createElement('script');
      script.id = scriptId;
      script.src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyDvXoER4O7m0dtJUynP2zQV_3vQ5WZs2B4';
      script.async = true;
      script.defer = true;
      script.onload = () => {
        if (typeof google !== 'undefined' && google.maps) {
          resolve();
          return;
        }
        reject(new Error('Google Maps loaded without maps API'));
      };
      script.onerror = () => reject(new Error('Failed to load Google Maps'));
      document.head.appendChild(script);
    });

    return this.loader;
  }
}
