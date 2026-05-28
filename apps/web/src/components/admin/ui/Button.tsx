import Link from 'next/link';
import type { ButtonHTMLAttributes, ReactNode } from 'react';

type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'success' | 'ghost' | 'link';

function variantClass(variant: ButtonVariant): string {
  switch (variant) {
    case 'primary':
      return 'admin-btn admin-btn-primary';
    case 'secondary':
      return 'admin-btn admin-btn-secondary';
    case 'danger':
      return 'admin-btn admin-btn-danger';
    case 'success':
      return 'admin-btn admin-btn-success';
    case 'ghost':
      return 'admin-btn admin-btn-ghost';
    case 'link':
      return 'admin-btn admin-btn-link';
    default:
      return 'admin-btn admin-btn-secondary';
  }
}

type AdminButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: ButtonVariant;
  loading?: boolean;
  children: ReactNode;
};

export function Button({
  variant = 'secondary',
  loading,
  disabled,
  className,
  children,
  ...props
}: AdminButtonProps) {
  return (
    <button
      type="button"
      className={[variantClass(variant), className].filter(Boolean).join(' ')}
      disabled={disabled || loading}
      {...props}
    >
      {loading ? 'Loading…' : children}
    </button>
  );
}

type AdminButtonLinkProps = {
  href: string;
  variant?: ButtonVariant;
  className?: string;
  children: ReactNode;
};

export function ButtonLink({ href, variant = 'secondary', className, children }: AdminButtonLinkProps) {
  return (
    <Link href={href} className={[variantClass(variant), className].filter(Boolean).join(' ')}>
      {children}
    </Link>
  );
}
