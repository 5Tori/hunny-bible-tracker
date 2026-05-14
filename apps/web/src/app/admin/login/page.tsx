'use client';

import { AdminGoogleLoginButton } from '@/components/AdminGoogleLoginButton';

export default function AdminLoginPage() {
  return (
    <main className="admin-login-page admin-shell">
      <section className="admin-login-card">
        <p className="eyebrow">Hunny Admin</p>
        <h1>Manage reading plans</h1>
        <p className="muted">
          Sign in with your Google account to access the admin dashboard.
        </p>

        <AdminGoogleLoginButton />
      </section>
    </main>
  );
}
