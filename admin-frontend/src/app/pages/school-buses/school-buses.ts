import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { BusService } from '../../services/bus.service';
import { Bus } from '../../models';
import { catchError, finalize, of, timeout } from 'rxjs';

@Component({
  selector: 'app-school-buses',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './school-buses.html',
  styleUrl: './school-buses.scss',
})
export class SchoolBuses implements OnInit {
  private busService = inject(BusService);
  private cdr = inject(ChangeDetectorRef);

  searchTerm = '';
  selectedStatus = '';
  totalBuses = 15;
  showDeleteConfirm = false;
  selectedBusPlate = '';
  selectedBusId?: number;
  isLoading = false;
  errorMessage = '';

  buses: Array<{
    id?: number;
    plate: string;
    model: string;
    capacity: string;
    status: string;
    conductorId: string;
    createdAt: string;
  }> = [];
  currentPage = 1;
  pageSize = 8;

  ngOnInit(): void {
    this.loadBuses();
  }

  loadBuses(): void {
    this.isLoading = true;
    this.errorMessage = '';
    const fallbackTimer = window.setTimeout(() => {
      if (this.isLoading) {
        this.isLoading = false;
        this.errorMessage = 'Failed to load buses. Please try again.';
        this.cdr.detectChanges();
      }
    }, 5000);

    this.busService.getAll().pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load buses:', error);
        this.errorMessage = error?.message || 'Failed to load buses.';
        return of([] as Bus[]);
      }),
      finalize(() => {
        this.isLoading = false;
        window.clearTimeout(fallbackTimer);
        this.cdr.detectChanges();
      })
    ).subscribe((buses) => {
      this.buses = buses.map((bus) => {
        return {
          id: bus.id ?? undefined,
          plate: bus.plateNumber,
          model: bus.model ?? 'N/A',
          capacity: bus.capacity ? `${bus.capacity} People` : 'N/A',
          status: bus.status ? bus.status.toString() : 'N/A',
          conductorId: bus.conductorId != null ? String(bus.conductorId) : 'N/A',
          createdAt: bus.createdAt ? new Date(bus.createdAt).toLocaleDateString() : 'N/A'
        };
      });
      this.totalBuses = buses.length;
      if (this.currentPage > this.totalPages) {
        this.currentPage = 1;
      }
      this.cdr.detectChanges();
    });
  }

  onFilterChange(): void {
    this.currentPage = 1;
  }

  openDeleteConfirm(plate: string, id?: number): void {
    this.selectedBusPlate = plate;
    this.selectedBusId = id;
    this.showDeleteConfirm = true;
  }

  closeDeleteConfirm(): void {
    this.showDeleteConfirm = false;
    this.selectedBusPlate = '';
    this.selectedBusId = undefined;
  }

  confirmDelete(): void {
    if (!this.selectedBusId) {
      this.closeDeleteConfirm();
      return;
    }
    this.busService.delete(this.selectedBusId).subscribe({
      next: () => {
        this.closeDeleteConfirm();
        this.loadBuses();
      },
      error: (error) => {
        console.error('Failed to delete bus:', error);
        this.errorMessage = 'Failed to delete bus. Please try again.';
        this.closeDeleteConfirm();
      }
    });
  }

  get filteredBuses(): Array<{
    id?: number;
    plate: string;
    model: string;
    capacity: string;
    status: string;
    conductorId: string;
    createdAt: string;
  }> {
    const term = this.searchTerm.trim().toLowerCase();
    return this.buses.filter((bus) => {
      const matchesTerm = !term || (
        bus.plate.toLowerCase().includes(term) ||
        bus.model.toLowerCase().includes(term) ||
        bus.status.toLowerCase().includes(term) ||
        bus.conductorId.toLowerCase().includes(term)
      );
      const matchesStatus = !this.selectedStatus || bus.status === this.selectedStatus;
      return matchesTerm && matchesStatus;
    });
  }

  get pagedBuses(): Array<{
    id?: number;
    plate: string;
    model: string;
    capacity: string;
    status: string;
    conductorId: string;
    createdAt: string;
  }> {
    const start = (this.currentPage - 1) * this.pageSize;
    return this.filteredBuses.slice(start, start + this.pageSize);
  }

  get totalPages(): number {
    return Math.max(1, Math.ceil(this.filteredBuses.length / this.pageSize));
  }

  get pageStart(): number {
    if (this.filteredBuses.length === 0) {
      return 0;
    }
    return (this.currentPage - 1) * this.pageSize + 1;
  }

  get pageEnd(): number {
    return Math.min(this.currentPage * this.pageSize, this.filteredBuses.length);
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
    return Array.from(new Set(this.buses.map((bus) => bus.status)))
      .filter((status) => status && status !== 'N/A')
      .sort();
  }
}
