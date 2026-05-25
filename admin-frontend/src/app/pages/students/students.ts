import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { StudentService } from '../../services/student.service';
import { ChildDetail } from '../../models';
import { catchError, finalize, of, timeout } from 'rxjs';

interface StudentViewModel {
  id: string;
  no: string;
  name: string;
  bus: string;
  route: string;
  stop: string;
  deviceId: string;
  location: string;
}

@Component({
  selector: 'app-students',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './students.html',
  styleUrl: './students.scss',
})
export class Students implements OnInit {
  private studentService = inject(StudentService);
  private cdr = inject(ChangeDetectorRef);

  searchTerm = '';
  selectedBus = '';
  selectedRoute = '';
  totalStudents = 0;
  showDeleteConfirm = false;
  selectedStudentId = '';
  selectedStudentName = '';
  isLoading = false;
  errorMessage = '';

  students: StudentViewModel[] = [];
  currentPage = 1;
  pageSize = 8;

  ngOnInit(): void {
    this.loadStudents();
  }

  loadStudents(): void {
    this.isLoading = true;
    this.errorMessage = '';
    const fallbackTimer = window.setTimeout(() => {
      if (this.isLoading) {
        this.isLoading = false;
        this.errorMessage = 'Failed to load students. Please try again.';
        this.cdr.detectChanges();
      }
    }, 5000);

    this.studentService.getAllWithDetails().pipe(
      timeout(5000),
      catchError((error) => {
        console.error('Failed to load students:', error);
        this.errorMessage = error?.message || 'Failed to load students.';
        return of([] as ChildDetail[]);
      }),
      finalize(() => {
        this.isLoading = false;
        window.clearTimeout(fallbackTimer);
        this.cdr.detectChanges();
      })
    ).subscribe((children) => {
      this.students = children.map((child, index) => this.mapChildToViewModel(child, index));
      this.totalStudents = children.length;
      if (this.currentPage > this.totalPages) {
        this.currentPage = 1;
      }
      this.cdr.detectChanges();
    });
  }

  onFilterChange(): void {
    this.currentPage = 1;
  }

  private mapChildToViewModel(child: ChildDetail, index: number): StudentViewModel {
    return {
      id: child.id || '',
      no: String(index + 1).padStart(2, '0'),
      name: child.fullName,
      bus: child.busPlateNumber || 'N/A',
      route: child.routeName || 'N/A',
      stop: child.busStopName || 'N/A',
      deviceId: child.busDeviceId || 'N/A',
      location: child.busStopLocation || 'N/A'
    };
  }

  openDeleteConfirm(id: string, name: string): void {
    this.selectedStudentId = id;
    this.selectedStudentName = name;
    this.showDeleteConfirm = true;
  }

  closeDeleteConfirm(): void {
    this.showDeleteConfirm = false;
    this.selectedStudentId = '';
    this.selectedStudentName = '';
  }

  confirmDelete(): void {
    if (!this.selectedStudentId) return;

    this.studentService.delete(this.selectedStudentId).subscribe({
      next: () => {
        this.closeDeleteConfirm();
        this.loadStudents();
      },
      error: (error) => {
        console.error('Failed to delete student:', error);
        this.errorMessage = 'Failed to delete student. Please try again.';
        this.closeDeleteConfirm();
      }
    });
  }

  get filteredStudents(): StudentViewModel[] {
    const term = this.searchTerm.trim().toLowerCase();
    return this.students.filter((student) => {
      const matchesTerm = !term || (
        student.name.toLowerCase().includes(term) ||
        student.bus.toLowerCase().includes(term) ||
        student.route.toLowerCase().includes(term) ||
        student.stop.toLowerCase().includes(term) ||
        student.deviceId.toLowerCase().includes(term) ||
        student.location.toLowerCase().includes(term)
      );
      const matchesBus = !this.selectedBus || student.bus === this.selectedBus;
      const matchesRoute = !this.selectedRoute || student.route === this.selectedRoute;
      return matchesTerm && matchesBus && matchesRoute;
    });
  }

  get pagedStudents(): StudentViewModel[] {
    const start = (this.currentPage - 1) * this.pageSize;
    return this.filteredStudents.slice(start, start + this.pageSize);
  }

  get totalPages(): number {
    return Math.max(1, Math.ceil(this.filteredStudents.length / this.pageSize));
  }

  get pageStart(): number {
    if (this.filteredStudents.length === 0) {
      return 0;
    }
    return (this.currentPage - 1) * this.pageSize + 1;
  }

  get pageEnd(): number {
    return Math.min(this.currentPage * this.pageSize, this.filteredStudents.length);
  }

  get busOptions(): string[] {
    return Array.from(new Set(this.students.map((student) => student.bus)))
      .filter((bus) => bus && bus !== 'N/A')
      .sort();
  }

  get routeOptions(): string[] {
    return Array.from(new Set(this.students.map((student) => student.route)))
      .filter((route) => route && route !== 'N/A')
      .sort();
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
}
