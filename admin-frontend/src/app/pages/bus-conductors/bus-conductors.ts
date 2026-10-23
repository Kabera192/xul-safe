import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { BusService } from '../../services/bus.service';
import { ConductorService } from '../../services/conductor.service';
import { RouteService } from '../../services/route.service';
import { Bus, Conductor, Route } from '../../models';
import { catchError, finalize, forkJoin, of, timeout } from 'rxjs';
import { applySort, initialSortState, SortState, sortIndicator, toggleSort } from '../../shared/table-sort';

type ConductorSortColumn = 'name' | 'bus' | 'route' | 'phone' | 'status';

interface ConductorRow {
  id: number;
  no: string;
  name: string;
  bus: string;
  route: string;
  phone: string;
  status: string;
}

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
  private routeService = inject(RouteService);
  private cdr = inject(ChangeDetectorRef);

  searchTerm = '';
  selectedStatus = '';
  totalConductors = 0;
  showDeleteConfirm = false;
  selectedConductorName = '';
  selectedConductorId?: number;
  isLoading = false;
  errorMessage = '';

  conductors: ConductorRow[] = [];

  currentPage = 1;
  pageSize = 8;
  sortState: SortState<ConductorSortColumn> = initialSortState();

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
      buses: this.busService.getAll(),
      routes: this.routeService.getAll().pipe(catchError(() => of([] as Route[])))
    }).pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load conductors:', error);
        this.errorMessage = error?.message || 'Failed to load conductors.';
        return of({ conductors: [] as Conductor[], buses: [] as Bus[], routes: [] as Route[] });
      }),
      finalize(() => {
        this.isLoading = false;
        window.clearTimeout(fallbackTimer);
        this.cdr.detectChanges();
      })
    ).subscribe(({ conductors, buses, routes }) => {
      const busByConductorId = new Map<number, Bus>();
      buses.forEach((bus) => {
        if (bus.conductorId != null) {
          busByConductorId.set(bus.conductorId, bus);
        }
      });

      this.conductors = conductors.map((conductor, index) => {
        const assignedBus = conductor.id != null ? busByConductorId.get(conductor.id) : undefined;
        const assignedRoute = assignedBus?.routeId != null
          ? routes.find((route) => route.id === assignedBus.routeId)
          : undefined;
        return {
          id: conductor.id ?? index,
          no: String(index + 1).padStart(2, '0'),
          name: conductor.fullName ?? 'N/A',
          bus: assignedBus?.plateNumber ?? 'N/A',
          route: assignedRoute?.name ?? 'N/A',
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
        this.cdr.detectChanges();
        this.loadConductors();
      },
      error: (error) => {
        console.error('Failed to delete conductor:', error);
        this.errorMessage = 'Failed to delete conductor. Please try again.';
        this.closeDeleteConfirm();
        this.cdr.detectChanges();
      }
    });
  }

  get filteredConductors(): ConductorRow[] {
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
        conductor.phone.toLowerCase().includes(term)
      )
    ));
  }

  get sortedConductors(): ConductorRow[] {
    return applySort(this.filteredConductors, this.sortState, (row, column) => row[column]);
  }

  sort(column: ConductorSortColumn): void {
    this.sortState = toggleSort(this.sortState, column);
  }

  sortArrow(column: ConductorSortColumn): string {
    return sortIndicator(this.sortState, column);
  }

  get pagedConductors(): ConductorRow[] {
    const start = (this.currentPage - 1) * this.pageSize;
    return this.sortedConductors.slice(start, start + this.pageSize);
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
