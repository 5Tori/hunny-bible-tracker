# Neon Auth Notes

This project no longer uses Neon Auth as the mobile authentication provider.

The current direction is:

- **Firebase Auth** for Google login
- **Neon Postgres** for application data
- **apps/web** API routes for Firebase ID token verification and Neon DB user upsert

See `docs/FIREBASE_AUTH.md` for the active setup.

## Why Neon Auth Was Replaced

The managed Neon Auth endpoint worked for basic credential flows, but native
Flutter Google Sign-In returned a browser OAuth redirect response instead of a
session when the app posted a Google `idToken` to `POST /sign-in/social`.

Because iOS and Android need reliable native Google login, the app moved to
Firebase Auth while keeping Neon as the database.
