import type { ReactNode } from 'react';

export type DataTableColumn = {
  key: string;
  header: string;
  className?: string;
};

type DataTableProps<T> = {
  tableClassName?: string;
  columns: DataTableColumn[];
  rows: T[];
  rowKey: (row: T) => string;
  renderCell: (row: T, columnKey: string) => ReactNode;
};

export function DataTable<T>({
  tableClassName = '',
  columns,
  rows,
  rowKey,
  renderCell,
}: DataTableProps<T>) {
  return (
    <div className={['admin-table', tableClassName].filter(Boolean).join(' ')}>
      <div className="admin-table-row admin-table-header">
        {columns.map((col) => (
          <span key={col.key}>{col.header}</span>
        ))}
      </div>
      {rows.map((row) => (
        <div key={rowKey(row)} className="admin-table-row">
          {columns.map((col) => (
            <span key={col.key} className={col.className}>
              {renderCell(row, col.key)}
            </span>
          ))}
        </div>
      ))}
    </div>
  );
}
