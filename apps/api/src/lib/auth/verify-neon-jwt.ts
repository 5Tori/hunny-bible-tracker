import { createRemoteJWKSet, jwtVerify, type JWTPayload } from 'jose';

let jwks: ReturnType<typeof createRemoteJWKSet> | null = null;

function getJwks() {
  const url = process.env.NEON_AUTH_JWKS_URL;
  if (!url?.trim()) {
    throw new Error('NEON_AUTH_JWKS_URL is not set');
  }
  if (!jwks) {
    jwks = createRemoteJWKSet(new URL(url.trim()));
  }
  return jwks;
}

/**
 * Verifies a Neon Auth JWT (EdDSA) using the project JWKS endpoint.
 */
export async function verifyNeonAuthBearerToken(token: string): Promise<JWTPayload> {
  const issuer = process.env.NEON_AUTH_JWT_ISSUER?.trim();
  const audience = process.env.NEON_AUTH_JWT_AUDIENCE?.trim();
  if (!issuer || !audience) {
    throw new Error('NEON_AUTH_JWT_ISSUER and NEON_AUTH_JWT_AUDIENCE must be set');
  }
  const { payload } = await jwtVerify(token, getJwks(), {
    issuer,
    audience,
  });
  return payload;
}
