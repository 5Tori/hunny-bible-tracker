import { cert, getApps, initializeApp, applicationDefault } from 'firebase-admin/app';
import { getAuth, type DecodedIdToken } from 'firebase-admin/auth';

function firebasePrivateKey() {
  const raw = process.env.FIREBASE_PRIVATE_KEY?.trim();
  if (!raw) return undefined;
  return raw.replace(/\\n/g, '\n');
}

function ensureFirebaseAdmin() {
  if (getApps().length > 0) return;

  const projectId = process.env.FIREBASE_PROJECT_ID?.trim();
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL?.trim();
  const privateKey = firebasePrivateKey();

  if (projectId && clientEmail && privateKey) {
    initializeApp({
      credential: cert({
        projectId,
        clientEmail,
        privateKey,
      }),
      projectId,
    });
    return;
  }

  initializeApp({
    credential: applicationDefault(),
    projectId,
  });
}

export async function verifyFirebaseBearerToken(
  token: string,
): Promise<DecodedIdToken> {
  ensureFirebaseAdmin();
  return getAuth().verifyIdToken(token);
}
