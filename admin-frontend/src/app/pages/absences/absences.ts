import { Component, OnInit, inject, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AbsenceService } from '../../services/absence.service';
import { Absence, AbsenceStatus } from '../../models';
import { catchError, finalize, timeout, of } from 'rxjs';
import { applySort, SortState, sortIndicator, toggleSort } from '../../shared/table-sort';

type AbsenceSortColumn = 'student' | 'absenceType' | 'startDate' | 'endDate' | 'status';

@Component({
  selector: 'app-absences',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './absences.html',
  styleUrl: './absences.scss',
})
export class AbsencesPage implements OnInit {
  private absenceService = inject(AbsenceService);
  private cdr = inject(ChangeDetectorRef);

  searchTerm = '';
  statusFilter: AbsenceStatus | 'ALL' = 'ALL';
  isLoading = false;
  errorMessage = '';
  absences: Absence[] = [];
  // Most recent first by default — otherwise rows sit in arbitrary load
  // order and old/new absences end up interleaved.
  sortState: SortState<AbsenceSortColumn> = { column: 'startDate', direction: 'desc' };

  readonly statusOptions: { value: AbsenceStatus | 'ALL'; label: string }[] = [
    { value: 'ALL', label: 'All statuses' },
    { value: 'ACTIVE', label: 'Active' },
    { value: 'COMPLETED', label: 'Completed' },
  ];

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.isLoading = true;
    this.errorMessage = '';

    this.absenceService.getAll().pipe(
      timeout(10000),
      catchError((err) => {
        console.error('Failed to load absences:', err);
        this.errorMessage = err.name === 'TimeoutError'
          ? 'Request timed out. Please try again.'
          : 'Failed to load absences.';
        return of([]);
      }),
      finalize(() => {
        this.isLoading = false;
        this.cdr.detectChanges();
      })
    ).subscribe((data) => {
      this.absences = data;
      this.cdr.detectChanges();
    });
  }

  get filtered(): Absence[] {
    return this.absences.filter(a => {
      const matchesStatus = this.statusFilter === 'ALL' || a.status === this.statusFilter;
      const term = this.searchTerm.toLowerCase().trim();
      const matchesSearch = !term ||
        (a.childName ?? a.childId).toLowerCase().includes(term) ||
        a.absenceType.toLowerCase().includes(term);
      return matchesStatus && matchesSearch;
    });
  }

  get sorted(): Absence[] {
    return applySort(this.filtered, this.sortState, (row, column) => {
      if (column === 'student') return row.childName ?? row.childId;
      return row[column];
    });
  }

  sort(column: AbsenceSortColumn): void {
    this.sortState = toggleSort(this.sortState, column);
  }

  sortArrow(column: AbsenceSortColumn): string {
    return sortIndicator(this.sortState, column);
  }

  get activeCount(): number {
    return this.absences.filter(a => a.status === 'ACTIVE').length;
  }

  get completedCount(): number {
    return this.absences.filter(a => a.status === 'COMPLETED').length;
  }

  formatType(type: string): string {
    return type.replace('_', ' ');
  }
}