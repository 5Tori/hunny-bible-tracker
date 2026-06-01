export const ADMIN_NAV_ITEMS = [
  { href: '/admin', label: 'Dashboard' },
  { href: '/admin/messages', label: 'Message cards' },
  { href: '/admin/today-messages', label: "Today's messages" },
  { href: '/admin/plans', label: 'Plans' },
  { href: '/admin/discover', label: 'Discover' },
] as const;

function matchesPathPrefix(pathname: string, href: string) {
  return pathname === href || pathname.startsWith(`${href}/`);
}

export function isAdminNavActive(href: string, pathname: string): boolean {
  if (href === '/admin') {
    return pathname === '/admin';
  }
  if (href === '/admin/plans') {
    return matchesPathPrefix(pathname, '/admin/plans');
  }
  if (href === '/admin/messages') {
    return matchesPathPrefix(pathname, '/admin/messages');
  }
  if (href === '/admin/discover') {
    if (matchesPathPrefix(pathname, '/admin/messages')) return false;
    return (
      matchesPathPrefix(pathname, '/admin/discover') || matchesPathPrefix(pathname, '/admin/content')
    );
  }
  if (href === '/admin/today-messages') {
    return matchesPathPrefix(pathname, '/admin/today-messages');
  }
  return matchesPathPrefix(pathname, href);
}

export function isAdminShellRoute(pathname: string): boolean {
  return pathname !== '/admin/login' && pathname.startsWith('/admin');
}
