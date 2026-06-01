import { redirect } from 'next/navigation';

export default function LegacyAdminContentPage() {
  redirect('/admin/discover');
}
