import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { BusService } from '../../services/bus.service';
import { ConductorService } from '../../services/conductor.service';
import { Bus, Conductor } from '../../models';
import { catchError, finalize, forkJoin, of, timeout } from 'rxjs';

@Component({
  selector: 'app-bus-conductors',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './bus-conductors.html',
  styleUrl: './bus-conductors.scss',
})
export class BusConductors implements OnInit {
  private conductorService = inject(ConductorService);
  private busService = inject(BusService);
  private cdr = inject(ChangeDetectorRef);

  searchTerm = '';
  selectedStatus = '';
  totalConductors = 0;
  showDeleteConfirm = false;
  selectedConductorName = '';
  selectedConductorId?: number;
  isLoading = false;
  errorMessage = '';

  conductors: Array<{
    id: number;
    no: string;
    name: string;
    bus: string;
    route: string;
    driverId: string;
    phone: string;
    status: string;
  }> = [];

  currentPage = 1;
  pageSize = 8;

  ngOnInit(): void {
    this.loadConductors();
  }

  loadConductors(): void {
    this.isLoading = true;
    this.errorMessage = '';
    const fallbackTimer = window.setTimeout(() => {
      if (this.isLoading) {
        this.isLoading = false;
        this.errorMessage = 'Failed to load conductors. Please try again.';
        this.cdr.detectChanges();
      }
    }, 5000);

    forkJoin({
      conductors: this.conductorService.getAll(),
      buses: this.busService.getAll()
    }).pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load conductors:', error);
        this.errorMessage = error?.message || 'Failed to load conductors.';
        return of({ conductors: [] as Conductor[], buses: [] as Bus[] });
      }),
      finalize(() => {
        this.isLoading = false;
        window.clearTimeout(fallbackTimer);
        this.cdr.detectChanges();
      })
    ).subscribe(({ conductors, buses }) => {
      const busByConductorId = new Map<number, Bus>();
      buses.forEach((bus) => {
        if (bus.conductorId != null) {
          busByConductorId.set(bus.conductorId, bus);
        }
      });

      this.conductors = conductors.map((conductor, index) => {
        const assignedBus = conductor.id != null ? busByConductorId.get(conductor.id) : undefined;
        return {
          id: conductor.id ?? index,
          no: String(index + 1).padStart(2, '0'),
          name: conductor.fullName ?? 'N/A',
          bus: assignedBus?.plateNumber ?? 'N/A',
          route: 'N/A',
          driverId: conductor.id != null ? `#DVR-${String(conductor.id).padStart(6, '0')}` : 'N/A',
          phone: conductor.phoneNumber ?? 'N/A',
          status: conductor.status ?? 'N/A'
        };
      });
      this.totalConductors = conductors.length;
      if (this.currentPage > this.totalPages) {
        this.currentPage = 1;
      }
      this.cdr.detectChanges();
    });
  }

  onFilterChange(): void {
    this.currentPage = 1;
  }

  openDeleteConfirm(id: number, name: string): void {
    this.selectedConductorId = id;
    this.selectedConductorName = name;
    this.showDeleteConfirm = true;
  }

  closeDeleteConfirm(): void {
    this.showDeleteConfirm = false;
    this.selectedConductorName = '';
    this.selectedConductorId = undefined;
  }

  confirmDelete(): void {
    if (!this.selectedConductorId) {
      this.closeDeleteConfirm();
      return;
    }
    this.conductorService.delete(this.selectedConductorId).subscribe({
      next: () => {
        this.closeDeleteConfirm();
        this.loadConductors();
      },
      error: (error) => {
        console.error('Failed to delete conductor:', error);
        this.errorMessage = 'Failed to delete conductor. Please try again.';
        this.closeDeleteConfirm();
      }
    });
  }

  get filteredConductors(): Array<{
    id: number;
    no: string;
    name: string;
    bus: string;
    route: string;
    driverId: string;
    phone: string;
    status: string;
  }> {
    const term = this.searchTerm.trim().toLowerCase();
    if (!term) {
      return this.conductors.filter((conductor) =>
        !this.selectedStatus || conductor.status === this.selectedStatus
      );
    }
    return this.conductors.filter((conductor) => (
      (!this.selectedStatus || conductor.status === this.selectedStatus) && (
        conductor.name.toLowerCase().includes(term) ||
        conductor.bus.toLowerCase().includes(term) ||
        conductor.driverId.toLowerCase().includes(term) ||
        conductor.phone.toLowerCase().includes(term)
      )
    ));
  }

  get pagedConductors(): Array<{
    id: number;
    no: string;
    name: string;
    bus: string;
    route: string;
    driverId: string;
    phone: string;
    status: string;
  }> {
    const start = (this.currentPage - 1) * this.pageSize;
    return this.filteredConductors.slice(start, start + this.pageSize);
  }

  get totalPages(): number {
    return Math.max(1, Math.ceil(this.filteredConductors.length / this.pageSize));
  }

  get pageStart(): number {
    if (this.filteredConductors.length === 0) {
      return 0;
    }
    return (this.currentPage - 1) * this.pageSize + 1;
  }

  get pageEnd(): number {
    return Math.min(this.currentPage * this.pageSize, this.filteredConductors.length);
  }

  goNext(): void {
    if (this.currentPage < this.totalPages) {
      this.currentPage += 1;
    }
  }

  goPrev(): void {
    if (this.currentPage > 1) {
      this.currentPage -= 1;
    }
  }

  get statusOptions(): string[] {
    return Array.from(new Set(this.conductors.map((conductor) => conductor.status)))
      .filter((status) => status && status !== 'N/A')
      .sort();
  }
}
