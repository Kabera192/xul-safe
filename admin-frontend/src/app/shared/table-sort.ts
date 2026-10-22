export type SortDirection = 'asc' | 'desc';

export interface SortState<Column extends string> {
  column: Column | null;
  direction: SortDirection;
}

/** Default state: unsorted (shows data in its original/load order). */
export function initialSortState<Column extends string>(): SortState<Column> {
  return { column: null, direction: 'asc' };
}

/**
 * Click handler for a sortable column header. First click on a column
 * sorts ascending; clicking the same column again flips to descending;
 * clicking a different column resets to ascending on that column.
 */
export function toggleSort<Column extends string>(
  state: SortState<Column>,
  column: Column
): SortState<Column> {
  if (state.column !== column) {
    return { column, direction: 'asc' };
  }
  return { column, direction: state.direction === 'asc' ? 'desc' : 'asc' };
}

/**
 * Text to show next to a sortable column header: a muted "unsorted" hint
 * on every column so admins can tell it's clickable at all, replaced by a
 * bold direction arrow on whichever column is actually active.
 */
export function sortIndicator<Column extends string>(
  state: SortState<Column>,
  column: Column
): string {
  if (state.column !== column) {
    return ' ⇅';
  }
  return state.direction === 'asc' ? ' ▲' : ' ▼';
}

/**
 * Sorts a copy of `rows` by the active column in `state`, using `accessor`
 * to read the comparable value for that column off each row. Returns
 * `rows` unchanged (same reference) when nothing is sorted yet.
 */
export function applySort<Row, Column extends string>(
  rows: Row[],
  state: SortState<Column>,
  accessor: (row: Row, column: Column) => string | number | null | undefined
): Row[] {
  if (!state.column) {
    return rows;
  }

  const column = state.column;
  const dir = state.direction === 'asc' ? 1 : -1;

  return [...rows].sort((a, b) => {
    const av = accessor(a, column);
    const bv = accessor(b, column);

    if (av == null && bv == null) return 0;
    if (av == null) return -1 * dir;
    if (bv == null) return 1 * dir;

    if (typeof av === 'number' && typeof bv === 'number') {
      return (av - bv) * dir;
    }

    return String(av).localeCompare(String(bv), undefined, { numeric: true }) * dir;
  });
}
