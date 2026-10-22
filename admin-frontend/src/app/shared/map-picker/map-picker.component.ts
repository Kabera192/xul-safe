import {
  AfterViewInit,
  Component,
  ElementRef,
  EventEmitter,
  Input,
  OnChanges,
  OnDestroy,
  Output,
  SimpleChanges,
  ViewChild,
  inject,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { GoogleMapsLoaderService } from '../google-maps-loader.service';

declare const google: any;

const KIGALI_FALLBACK = { lat: -1.9441, lng: 30.0619 };

/**
 * Shared map display/picker, backed by the Google Maps JS SDK with an
 * iframe fallback if the SDK fails to load (same pattern request-details
 * used before this was extracted). In `editable` mode, clicking the map
 * drops/moves a marker and emits the picked coordinates — used by the
 * bus-stop editor so admins get the same map UX as the request-details
 * view instead of blind lat/lng number fields.
 */
@Component({
  selector: 'app-map-picker',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './map-picker.component.html',
  styleUrl: './map-picker.component.scss',
})
export class MapPickerComponent implements AfterViewInit, OnChanges, OnDestroy {
  private mapsLoader = inject(GoogleMapsLoaderService);
  private sanitizer = inject(DomSanitizer);

  @Input() lat: number | null = null;
  @Input() lng: number | null = null;
  @Input() editable = false;
  @Input() zoom = 15;
  @Output() positionPicked = new EventEmitter<{ lat: number; lng: number }>();

  @ViewChild('mapContainer') mapContainer?: ElementRef<HTMLDivElement>;

  mapError = '';

  private map: any;
  private marker: any;
  private clickListener: any;
  private viewReady = false;

  ngAfterViewInit(): void {
    this.viewReady = true;
    this.tryInit();
  }

  ngOnChanges(changes: SimpleChanges): void {
    if ((changes['lat'] || changes['lng']) && this.map) {
      this.syncMarker();
    } else {
      this.tryInit();
    }
  }

  ngOnDestroy(): void {
    this.clickListener?.remove();
  }

  private tryInit(): void {
    if (!this.viewReady || !this.mapContainer || this.map) {
      return;
    }

    this.mapsLoader
      .load()
      .then(() => {
        const center = this.hasCoordinates ? { lat: this.lat!, lng: this.lng! } : KIGALI_FALLBACK;

        this.map = new google.maps.Map(this.mapContainer!.nativeElement, {
          center,
          zoom: this.zoom,
          mapTypeControl: false,
          streetViewControl: false,
        });

        if (this.hasCoordinates) {
          this.marker = new google.maps.Marker({ position: center, map: this.map });
        }

        if (this.editable) {
          this.clickListener = this.map.addListener('click', (e: any) => {
            const position = { lat: e.latLng.lat(), lng: e.latLng.lng() };
            this.setMarker(position);
            this.positionPicked.emit(position);
          });
        }
      })
      .catch((error: unknown) => {
        console.error('Failed to load Google Maps:', error);
        this.mapError = 'Map unavailable.';
      });
  }

  private syncMarker(): void {
    if (!this.map || !this.hasCoordinates) {
      return;
    }
    const position = { lat: this.lat!, lng: this.lng! };
    this.map.setCenter(position);
    this.setMarker(position);
  }

  private setMarker(position: { lat: number; lng: number }): void {
    if (!this.marker) {
      this.marker = new google.maps.Marker({ position, map: this.map });
    } else {
      this.marker.setPosition(position);
    }
  }

  get hasCoordinates(): boolean {
    return (
      this.lat != null &&
      this.lng != null &&
      Number.isFinite(this.lat) &&
      Number.isFinite(this.lng)
    );
  }

  get fallbackUrl(): SafeResourceUrl | null {
    if (!this.hasCoordinates) {
      return null;
    }
    return this.sanitizer.bypassSecurityTrustResourceUrl(
      `https://www.google.com/maps?q=${this.lat},${this.lng}&z=${this.zoom}&output=embed`
    );
  }
}
