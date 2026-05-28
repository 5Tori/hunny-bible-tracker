'use client';

import { AdminGoogleLoginButton } from '@/components/AdminGoogleLoginButton';

export default function AdminLoginPage() {
  return (
    <main className="admin-login-page">
      <section className="admin-login-card">
        <p className="admin-page-header-label">Admin</p>
        <h1>Sign in</h1>
        <p>Sign in with Google to manage plans, content, and today&apos;s messages.</p>
        <AdminGoogleLoginButton />
      </section>
    </main>
  );
}
