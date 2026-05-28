export const ADMIN_NAV_ITEMS = [
  { href: '/admin/plans', label: 'Plans' },
  { href: '/admin/content', label: 'Content' },
  { href: '/admin/today-messages', label: "Today's messages" },
] as const;

export function isAdminNavActive(href: string, pathname: string): boolean {
  if (href === '/admin/plans') {
    return pathname === '/admin/plans' || pathname.startsWith('/admin/plans/');
  }
  if (href === '/admin/content') {
    if (pathname === '/admin/content' || pathname === '/admin/content/new') return true;
    if (pathname.startsWith('/admin/content/')) return true;
    return false;
  }
  if (href === '/admin/today-messages') {
    if (pathname === '/admin/today-messages' || pathname === '/admin/today-messages/new') return true;
    if (pathname.startsWith('/admin/today-messages/')) return true;
    return false;
  }
  return pathname === href || pathname.startsWith(`${href}/`);
}

export function isAdminShellRoute(pathname: string): boolean {
  return pathname !== '/admin/login' && pathname.startsWith('/admin');
}
