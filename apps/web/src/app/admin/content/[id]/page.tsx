import { redirect } from 'next/navigation';

interface PageProps {
  params: Promise<{ id: string }>;
}

export default async function LegacyEditAdminContentPage({ params }: PageProps) {
  const { id } = await params;
  redirect(`/admin/discover/${id}`);
}
