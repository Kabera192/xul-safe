import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { RouteService } from '../../services/route.service';
import { StudentService } from '../../services/student.service';
import { ChildDetail, RouteRequest } from '../../models';
import { catchError, finalize, forkJoin, of, timeout } from 'rxjs';

@Component({
  selector: 'app-user-requests',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './user-requests.html',
  styleUrl: './user-requests.scss',
})
export class UserRequests implements OnInit {
  private routeService = inject(RouteService);
  private studentService = inject(StudentService);
  private cdr = inject(ChangeDetectorRef);

  searchTerm = '';
  activeTab: 'bus-stop' = 'bus-stop';
  isLoading = false;
  errorMessage = '';

  busStopRequests: Array<{
    id: string;
    no: string;
    parentId: string;
    childName: string;
    date: string;
    address: string;
    description: string;
    status: string;
  }> = [];


  ngOnInit(): void {
    this.loadRouteRequests();
  }

  private loadRouteRequests(): void {
    this.isLoading = true;
    this.errorMessage = '';
    const fallbackTimer = window.setTimeout(() => {
      if (this.isLoading) {
        this.isLoading = false;
        this.errorMessage = 'Failed to load requests. Please try again.';
        this.cdr.detectChanges();
      }
    }, 5000);

    forkJoin({
      requests: this.routeService.getRouteRequests().pipe(
        timeout(5000),
        catchError((error) => {
          console.error('Failed to load route requests:', error);
          this.errorMessage = error?.message || 'Failed to load requests.';
          return of([] as RouteRequest[]);
        })
      ),
      children: this.studentService.getAllWithDetails().pipe(
        timeout(5000),
        catchError((error) => {
          console.error('Failed to load students:', error);
          return of([] as ChildDetail[]);
        })
      )
    }).pipe(
      finalize(() => {
        this.isLoading = false;
        window.clearTimeout(fallbackTimer);
        this.cdr.detectChanges();
      })
    ).subscribe(({ requests, children }) => {
      const childNameById = new Map<string, string>();
      children.forEach((child) => {
        if (child.id) {
          childNameById.set(child.id, child.fullName ?? 'N/A');
        }
      });

      this.busStopRequests = requests.map((request, index) => ({
        id: String(request.id ?? index),
        no: String(index + 1).padStart(2, '0'),
        parentId: request.parentId != null ? String(request.parentId) : 'N/A',
        childName: childNameById.get(request.childId) ?? 'Unknown child',
        date: request.createdAt ? new Date(request.createdAt).toLocaleDateString() : 'N/A',
        address: request.address ?? 'N/A',
        description: request.description ?? 'N/A',
        status: request.status ?? 'PENDING'
      }));
      this.cdr.detectChanges();
    });
  }

  get filteredBusStopRequests(): Array<{
    id: string;
    no: string;
    parentId: string;
    childName: string;
    date: string;
    address: string;
    description: string;
    status: string;
  }> {
    const term = this.searchTerm.trim().toLowerCase();
    if (!term) {
      return this.busStopRequests;
    }
    return this.busStopRequests.filter((request) =>
      request.parentId.toLowerCase().includes(term) ||
      request.childName.toLowerCase().includes(term) ||
      request.address.toLowerCase().includes(term) ||
      request.description.toLowerCase().includes(term) ||
      request.status.toLowerCase().includes(term)
    );
  }
}
