import { Component, OnInit, inject, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AbsenceService } from '../../services/absence.service';
import { Absence, AbsenceStatus } from '../../models';
import { catchError, finalize, timeout, of } from 'rxjs';

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

  readonly statusOptions: { value: AbsenceStatus | 'ALL'; label: string }[] = [
    { value: 'ALL', label: 'All statuses' },
    { value: 'ACTIVE', label: 'Active' },
    { value: 'COMPLETED', label: 'Completed' },
    { value: 'CANCELLED', label: 'Cancelled' },
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

  get activeCount(): number {
    return this.absences.filter(a => a.status === 'ACTIVE').length;
  }

  get completedCount(): number {
    return this.absences.filter(a => a.status === 'COMPLETED').length;
  }

  get cancelledCount(): number {
    return this.absences.filter(a => a.status === 'CANCELLED').length;
  }

  formatType(type: string): string {
    return type.replace('_', ' ');
  }
}