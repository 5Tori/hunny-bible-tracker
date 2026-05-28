import type { ReactNode } from 'react';

type FormFieldProps = {
  label: string;
  htmlFor?: string;
  hint?: string;
  error?: string;
  children: ReactNode;
};

export function FormField({ label, htmlFor, hint, error, children }: FormFieldProps) {
  return (
    <div className="admin-field">
      <label htmlFor={htmlFor}>{label}</label>
      {children}
      {hint ? <p className="admin-field-hint">{hint}</p> : null}
      {error ? <p className="admin-field-error">{error}</p> : null}
    </div>
  );
}
