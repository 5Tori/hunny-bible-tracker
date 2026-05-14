import { DecodedIdToken } from 'firebase-admin/auth';
import { verifyFirebaseBearerToken } from '@/lib/auth/verify-firebase-token';

export class AdminAuthError extends Error {
  status: number;
  code: string;

  constructor(code: string, message: string, status: number) {
    super(message);
    this.code = code;
    this.status = status;
  }
}

export function parseBearerToken(req: Request) {
  const authorization = req.headers.get('authorization');
  if (!authorization?.toLowerCase().startsWith('bearer ')) {
    throw new AdminAuthError('missing_bearer', 'Authorization header is missing', 401);
  }
  const token = authorization.slice(7).trim();
  if (!token) {
    throw new AdminAuthError('missing_token', 'Bearer token is missing', 401);
  }
  return token;
}

export function getAdminEmailSet(): Set<string> {
  return new Set(
    (process.env.ADMIN_EMAILS ?? '')
      .split(',')
      .map((email) => email.trim().toLowerCase())
      .filter(Boolean),
  );
}

export function isAdminEmail(email?: string | null) {
  if (!email) return false;
  return getAdminEmailSet().has(email.toLowerCase());
}

export async function verifyAdminToken(token: string): Promise<DecodedIdToken> {
  const payload = await verifyFirebaseBearerToken(token);
  if (!isAdminEmail(typeof payload.email === 'string' ? payload.email : null)) {
    throw new AdminAuthError('not_authorized', 'User is not configured as an admin', 403);
  }
  return payload;
}

export async function requireAdminUser(req: Request): Promise<DecodedIdToken> {
  const token = parseBearerToken(req);
  try {
    return await verifyAdminToken(token);
  } catch (error) {
    if (error instanceof AdminAuthError) {
      throw error;
    }
    throw new AdminAuthError('invalid_token', 'Unable to verify Firebase token', 401);
  }
}
