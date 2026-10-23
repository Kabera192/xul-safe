import { Component, OnDestroy, OnInit, inject, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IncidentService } from '../../services/incident.service';
import { BusService } from '../../services/bus.service';
import { UserService } from '../../services/user.service';
import {
  Incident,
  IncidentAttachment,
  IncidentStatus,
  IncidentType,
  JourneyImpact,
} from '../../models';
import { catchError, of, finalize, forkJoin } from 'rxjs';
import { applySort, initialSortState, SortState, sortIndicator, toggleSort } from '../../shared/table-sort';

type IncidentSortColumn = 'type' | 'reportedBy' | 'busAffected' | 'status' | 'reportedAt';

interface IncidentRow {
  id: number;
  type: IncidentType;
  description: string;
  status: IncidentStatus;
  journeyImpact: JourneyImpact;
  reportedBy: string;
  busAffected: string;
  reportedAt: string;
  reportedAtValue: number | null;
}

interface AttachmentPreview {
  id: number;
  type: 'IMAGE' | 'AUDIO';
  objectUrl: string;
}

@Component({
  selector: 'app-incidents',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './incidents.html',
  styleUrl: './incidents.scss',
})
export class Incidents implements OnInit, OnDestroy {
  private incidentService = inject(IncidentService);
  private busService = inject(BusService);
  private userService = inject(UserService);
  private cdr = inject(ChangeDetectorRef);

  isLoading = false;
  searchTerm = '';

  // Detail side panel
  showDetailPanel = false;
  selectedIncident: IncidentRow | null = null;
  isLoadingAttachments = false;
  attachmentPreviews: AttachmentPreview[] = [];

  incidentRows: IncidentRow[] = [];
  incidentSortState: SortState<IncidentSortColumn> = initialSortState();

  ngOnInit(): void {
    this.loadIncidents();
  }

  ngOnDestroy(): void {
    this.revokeAttachmentUrls();
  }

  loadIncidents(): void {
    this.isLoading = true;

    forkJoin({
      incidents: this.incidentService.getAll().pipe(catchError(() => of([] as Incident[]))),
      buses: this.busService.getAll().pipe(catchError(() => of([])))
    }).pipe(
      finalize(() => {
        this.isLoading = false;
        this.cdr.detectChanges();
      })
    ).subscribe(({ incidents, buses }) => {
      const busPlateById = new Map<number, string>();
      buses.forEach((bus) => {
        if (bus.id != null) busPlateById.set(bus.id, bus.plateNumber);
      });

      const reporterIds = [...new Set(
        incidents.map((i) => i.createdBy).filter((id): id is number => id != null)
      )];

      forkJoin(
        reporterIds.length > 0
          ? reporterIds.map((id) => this.userService.getProfile(id).pipe(catchError(() => of(null))))
          : [of(null)]
      ).subscribe((reporters) => {
        const reporterNameById = new Map<number, string>();
        reporterIds.forEach((id, i) => {
          const user = reporters[i];
          reporterNameById.set(id, user ? `${user.firstName} ${user.lastName}`.trim() : 'Unknown');
        });

        this.incidentRows = incidents.map((incident) => ({
          id: incident.id,
          type: incident.type,
          description: incident.description,
          status: incident.status,
          journeyImpact: incident.journeyImpact,
          reportedBy: incident.createdBy != null
            ? (reporterNameById.get(incident.createdBy) ?? 'Unknown')
            : 'N/A',
          busAffected: (incident.affectedBusIds ?? [])
            .map((busId) => busPlateById.get(busId) ?? `#${busId}`)
            .join(', ') || 'N/A',
          reportedAt: incident.createdAt
            ? new Date(incident.createdAt).toLocaleString('en-GB')
            : 'N/A',
          reportedAtValue: incident.createdAt ?? null,
        }));
        this.cdr.detectChanges();
      });
    });
  }

  get filteredIncidentRows(): IncidentRow[] {
    const term = this.searchTerm.trim().toLowerCase();
    if (!term) {
      return this.incidentRows;
    }
    return this.incidentRows.filter((incident) =>
      incident.type.toLowerCase().includes(term) ||
      incident.description.toLowerCase().includes(term) ||
      incident.reportedBy.toLowerCase().includes(term) ||
      incident.busAffected.toLowerCase().includes(term) ||
      incident.status.toLowerCase().includes(term)
    );
  }

  get sortedIncidentRows(): IncidentRow[] {
    return applySort(this.filteredIncidentRows, this.incidentSortState, (row, column) => {
      if (column === 'reportedAt') return row.reportedAtValue;
      return row[column];
    });
  }

  sortIncidents(column: IncidentSortColumn): void {
    this.incidentSortState = toggleSort(this.incidentSortState, column);
  }

  incidentSortArrow(column: IncidentSortColumn): string {
    return sortIndicator(this.incidentSortState, column);
  }

  get newIncidentCount(): number {
    return this.incidentRows.filter(i => i.status === 'ACTIVE').length;
  }

  openDetail(row: IncidentRow): void {
    this.selectedIncident = row;
    this.showDetailPanel = true;
    this.loadAttachments(row.id);
  }

  closeDetail(): void {
    this.showDetailPanel = false;
    this.selectedIncident = null;
    this.revokeAttachmentUrls();
    this.attachmentPreviews = [];
  }

  private loadAttachments(incidentId: number): void {
    this.revokeAttachmentUrls();
    this.attachmentPreviews = [];
    this.isLoadingAttachments = true;

    this.incidentService.getAttachments(incidentId).pipe(
      catchError(() => of([] as IncidentAttachment[]))
    ).subscribe((attachments) => {
      if (attachments.length === 0) {
        this.isLoadingAttachments = false;
        this.cdr.detectChanges();
        return;
      }

      forkJoin(
        attachments.map((attachment) =>
          this.incidentService.getAttachmentBlob(incidentId, attachment.id).pipe(
            catchError(() => of(null))
          )
        )
      ).pipe(
        finalize(() => {
          this.isLoadingAttachments = false;
          this.cdr.detectChanges();
        })
      ).subscribe((blobs) => {
        this.attachmentPreviews = attachments
          .map((attachment, i) => {
            const blob = blobs[i];
            if (!blob) return null;
            return {
              id: attachment.id,
              type: attachment.type,
              objectUrl: URL.createObjectURL(blob),
            };
          })
          .filter((preview): preview is AttachmentPreview => preview !== null);
      });
    });
  }

  private revokeAttachmentUrls(): void {
    this.attachmentPreviews.forEach((preview) => URL.revokeObjectURL(preview.objectUrl));
  }
}
