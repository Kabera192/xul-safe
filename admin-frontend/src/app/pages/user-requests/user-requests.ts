import { ChangeDetectorRef, Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { RouteService } from '../../services/route.service';
import { StudentService } from '../../services/student.service';
import { UserService } from '../../services/user.service';
import { ChildDetail, RouteRequest } from '../../models';
import { catchError, finalize, forkJoin, of, timeout } from 'rxjs';
import { applySort, initialSortState, SortState, sortIndicator, toggleSort } from '../../shared/table-sort';

type RequestSortColumn = 'parentName' | 'childName' | 'date' | 'address' | 'description' | 'status';

interface BusStopRequestRow {
  id: string;
  no: string;
  parentName: string;
  childName: string;
  date: string;
  dateValue: number | null;
  address: string;
  description: string;
  status: string;
}

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
  private userService = inject(UserService);
  private cdr = inject(ChangeDetectorRef);

  searchTerm = '';
  activeTab: 'bus-stop' = 'bus-stop';
  isLoading = false;
  errorMessage = '';

  busStopRequests: BusStopRequestRow[] = [];
  sortState: SortState<RequestSortColumn> = initialSortState();


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

      const parentIds = [...new Set(
        requests.map((r) => r.parentId).filter((id): id is number => id != null)
      )];

      forkJoin(
        parentIds.map((parentId) =>
          this.userService.getProfile(parentId).pipe(
            catchError(() => of(null))
          )
        )
      ).subscribe((parents) => {
        const parentNameById = new Map<number, string>();
        parentIds.forEach((parentId, i) => {
          const parent = parents[i];
          parentNameById.set(
            parentId,
            parent ? `${parent.firstName} ${parent.lastName}`.trim() : 'Unknown parent'
          );
        });

        this.busStopRequests = requests.map((request, index) => ({
          id: String(request.id ?? index),
          no: String(index + 1).padStart(2, '0'),
          parentName: request.parentId != null
            ? (parentNameById.get(request.parentId) ?? 'Unknown parent')
            : 'N/A',
          childName: childNameById.get(request.childId) ?? 'Unknown child',
          date: request.createdAt ? new Date(request.createdAt).toLocaleDateString() : 'N/A',
          dateValue: request.createdAt ?? null,
          address: request.address ?? 'N/A',
          description: request.description ?? 'N/A',
          status: request.status ?? 'PENDING'
        }));
        this.cdr.detectChanges();
      });
    });
  }

  get filteredBusStopRequests(): BusStopRequestRow[] {
    const term = this.searchTerm.trim().toLowerCase();
    if (!term) {
      return this.busStopRequests;
    }
    return this.busStopRequests.filter((request) =>
      request.parentName.toLowerCase().includes(term) ||
      request.childName.toLowerCase().includes(term) ||
      request.address.toLowerCase().includes(term) ||
      request.description.toLowerCase().includes(term) ||
      request.status.toLowerCase().includes(term)
    );
  }

  get sortedBusStopRequests(): BusStopRequestRow[] {
    return applySort(this.filteredBusStopRequests, this.sortState, (row, column) => {
      if (column === 'date') return row.dateValue;
      return row[column];
    });
  }

  sort(column: RequestSortColumn): void {
    this.sortState = toggleSort(this.sortState, column);
  }

  sortArrow(column: RequestSortColumn): string {
    return sortIndicator(this.sortState, column);
  }
}
