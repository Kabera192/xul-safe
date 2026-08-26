import { Component, OnInit, inject, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { JourneyService } from '../../services/journey.service';
import { AttendanceMark } from '../../models';
import { catchError, finalize, timeout, of } from 'rxjs';

type AttendanceRow = {
  no: string;
  name: string;
  bus: string;
  mon: AttendanceMark[];
  tue: AttendanceMark[];
  wed: AttendanceMark[];
  thu: AttendanceMark[];
  fri: AttendanceMark[];
};

@Component({
  selector: 'app-trip-attendance',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './trip-attendance.html',
  styleUrl: './trip-attendance.scss',
})
export class TripAttendance implements OnInit {
  private journeyService = inject(JourneyService);
  private cdr = inject(ChangeDetectorRef);

  searchTerm = '';
  periodLabel = '';
  isLoading = false;
  errorMessage = '';

  // Detail side panel
  showDetailPanel = false;
  selectedRow: AttendanceRow | null = null;

  currentWeekStart: Date = this.getMonday(new Date());
  rows: AttendanceRow[] = [];

  ngOnInit(): void {
    this.loadAttendance();
  }

  loadAttendance(): void {
    this.isLoading = true;
    this.errorMessage = '';
    this.rows = [];
    this.updatePeriodLabel();

    const weekStartStr = this.formatDate(this.currentWeekStart);

    this.journeyService.getWeeklyAttendance(weekStartStr).pipe(
      timeout(10000),
      catchError((err) => {
        console.error('Failed to load attendance:', err);
        this.errorMessage = err.name === 'TimeoutError'
          ? 'Request timed out. Please try again.'
          : 'Failed to load attendance data.';
        return of([]);
      }),
      finalize(() => {
        this.isLoading = false;
        this.cdr.detectChanges();
      })
    ).subscribe((data) => {
      this.rows = data.map((item, index) => ({
        no: String(index + 1).padStart(2, '0'),
        name: item.childName || 'Unknown',
        bus: item.busPlateNumber || item.routeName || 'N/A',
        mon: item.mon || [],
        tue: item.tue || [],
        wed: item.wed || [],
        thu: item.thu || [],
        fri: item.fri || [],
      }));
      this.cdr.detectChanges();
    });
  }

  previousWeek(): void {
    this.currentWeekStart = new Date(this.currentWeekStart);
    this.currentWeekStart.setDate(this.currentWeekStart.getDate() - 7);
    this.loadAttendance();
  }

  nextWeek(): void {
    if (!this.canGoNext) return;
    this.currentWeekStart = new Date(this.currentWeekStart);
    this.currentWeekStart.setDate(this.currentWeekStart.getDate() + 7);
    this.loadAttendance();
  }

  /** Jump straight to the week containing an arbitrary picked date. */
  onDatePicked(value: string): void {
    if (!value) return;
    const [year, month, day] = value.split('-').map(Number);
    if (!year || !month || !day) return;
    this.currentWeekStart = this.getMonday(new Date(year, month - 1, day));
    this.loadAttendance();
  }

  /** The current week can't be navigated past — there's nothing to show yet. */
  get canGoNext(): boolean {
    return this.getMonday(new Date()).getTime() > this.currentWeekStart.getTime();
  }

  /** Caps the date picker so admins can't jump into a future week either. */
  get todayStr(): string {
    return this.formatDate(new Date());
  }

  private getMonday(date: Date): Date {
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    const day = d.getDay();
    const diff = d.getDate() - day + (day === 0 ? -6 : 1);
    d.setDate(diff);
    return d;
  }

  /**
   * Builds a plain "yyyy-MM-dd" string from the Date's LOCAL calendar fields.
   * Using `toISOString()` here would convert to UTC first, which silently
   * shifts the date by a day for any timezone ahead of UTC in the early
   * morning — throwing off which week is requested from the backend.
   */
  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  private updatePeriodLabel(): void {
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const start = this.currentWeekStart;
    const end = new Date(start);
    end.setDate(end.getDate() + 4);

    const startLabel = `${monthNames[start.getMonth()]} ${start.getDate()}`;
    const endLabel = start.getMonth() === end.getMonth()
      ? `${end.getDate()}`
      : `${monthNames[end.getMonth()]} ${end.getDate()}`;

    this.periodLabel = `${startLabel}–${endLabel}, ${end.getFullYear()}`;
  }

  get filteredRows(): AttendanceRow[] {
    if (!this.searchTerm.trim()) {
      return this.rows;
    }
    const term = this.searchTerm.toLowerCase();
    return this.rows.filter(row =>
      row.name.toLowerCase().includes(term) ||
      row.bus.toLowerCase().includes(term)
    );
  }

  isPresent(mark: AttendanceMark): boolean {
    return mark === 'present';
  }

  isPending(mark: AttendanceMark): boolean {
    return mark === 'pending';
  }

  isAbsent(mark: AttendanceMark): boolean {
    return mark === 'absent';
  }

  openDetail(row: AttendanceRow): void {
    this.selectedRow = row;
    this.showDetailPanel = true;
  }

  closeDetail(): void {
    this.showDetailPanel = false;
    this.selectedRow = null;
  }

  downloadReport(): void {
    this.printPdf(this.filteredRows, `Attendance — ${this.periodLabel}`);
  }

  downloadRowReport(row: AttendanceRow): void {
    this.printPdf([row], `${row.name} — Attendance — ${this.periodLabel}`);
  }

  private printPdf(rows: AttendanceRow[], title: string): void {
    const days: { label: string; key: keyof AttendanceRow }[] = [
      { label: 'Monday',    key: 'mon' },
      { label: 'Tuesday',   key: 'tue' },
      { label: 'Wednesday', key: 'wed' },
      { label: 'Thursday',  key: 'thu' },
      { label: 'Friday',    key: 'fri' },
    ];

    const badge = (mark: AttendanceMark | undefined) => {
      if (mark === 'present') {
        return '<span style="display:inline-block;background:#D1FAE5;color:#065F46;font-weight:700;font-size:10px;padding:2px 8px;border-radius:4px;white-space:nowrap;">✓ Present</span>';
      }
      if (mark === 'pending') {
        return '<span style="display:inline-block;background:#F3F4F6;color:#6B7280;font-weight:700;font-size:10px;padding:2px 8px;border-radius:4px;white-space:nowrap;">• Upcoming</span>';
      }
      return '<span style="display:inline-block;background:#FEE2E2;color:#991B1B;font-weight:700;font-size:10px;padding:2px 8px;border-radius:4px;white-space:nowrap;">✗ Absent</span>';
    };

    const tableRows = rows.map(row => `
      <tr>
        <td class="no">${row.no}</td>
        <td>${row.name}</td>
        <td>${row.bus}</td>
        ${days.map(d => {
          const marks = row[d.key] as AttendanceMark[];
          return `<td>
            <div style="display:flex;flex-direction:column;gap:4px;align-items:flex-start;">
              <div style="display:flex;align-items:center;gap:6px;">
                <span style="font-size:9px;color:#9CA3AF;width:16px;">AM</span>${badge(marks[0])}
              </div>
              <div style="display:flex;align-items:center;gap:6px;">
                <span style="font-size:9px;color:#9CA3AF;width:16px;">PM</span>${badge(marks[1])}
              </div>
            </div>
          </td>`;
        }).join('')}
      </tr>`).join('');

    const html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>${title}</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: 'Segoe UI', Arial, sans-serif; font-size: 12px; color: #111827; padding: 24px; }
    h1 { font-size: 16px; font-weight: 700; margin-bottom: 4px; color: #111827; }
    .subtitle { font-size: 11px; color: #6B7280; margin-bottom: 20px; }
    table { width: 100%; border-collapse: collapse; table-layout: fixed; }
    thead tr { background: #F5F7FF; }
    th { padding: 8px 10px; text-align: left; font-size: 10px; text-transform: uppercase;
         letter-spacing: 0.05em; color: #1A56DB; border-bottom: 2px solid #E5E7EB; }
    th:first-child { width: 40px; }
    th:nth-child(2) { width: 140px; }
    th:nth-child(3) { width: 80px; }
    td { padding: 8px 10px; border-bottom: 1px solid #E5E7EB; vertical-align: middle; }
    tr:last-child td { border-bottom: none; }
    tr:nth-child(even) { background: #F9FAFB; }
    .no { color: #1A56DB; font-weight: 600; }
    .legend { margin-top: 16px; display: flex; gap: 20px; font-size: 10px; color: #6B7280; align-items: center; }
    @media print {
      body { padding: 16px; }
      -webkit-print-color-adjust: exact;
      print-color-adjust: exact;
    }
  </style>
</head>
<body>
  <h1>${title}</h1>
  <p class="subtitle">Generated ${new Date().toLocaleDateString('en-GB', { day: '2-digit', month: 'long', year: 'numeric' })}</p>
  <table>
    <thead>
      <tr>
        <th>#</th>
        <th>Student name</th>
        <th>Bus</th>
        ${days.map(d => `<th>${d.label}</th>`).join('')}
      </tr>
    </thead>
    <tbody>${tableRows}</tbody>
  </table>
  <div class="legend">
    <span style="display:inline-block;background:#D1FAE5;color:#065F46;font-weight:700;font-size:10px;padding:2px 8px;border-radius:4px;">✓ Present</span>
    <span style="display:inline-block;background:#FEE2E2;color:#991B1B;font-weight:700;font-size:10px;padding:2px 8px;border-radius:4px;">✗ Absent</span>
  </div>
</body>
</html>`;

    const win = window.open('', '_blank', 'width=1000,height=650');
    if (!win) return;
    win.document.write(html);
    win.document.close();
    win.focus();
    setTimeout(() => {
      win.print();
      win.close();
    }, 300);
  }
}
