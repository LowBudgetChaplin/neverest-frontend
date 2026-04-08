# Neverest Mobile

Flutter client for the Neverest backend.

## Part 1 Scope (implemented)

- Switched app state management to BLoC (`flutter_bloc`)
- Added a BLoC-based app shell with 5 tabs: Home, Events, Challenges, Rewards, Leaderboard
- Connected read-only backend endpoints:
  - `GET /hello`
  - `GET /api/v1/events`
  - `GET /api/v1/challenges`
  - `GET /api/v1/rewards`
  - `GET /api/v1/leaderboard/general?limit=20`
- Added refresh support from app bar
- Added optional bearer token injection in API client (`flutter_secure_storage`)

## Part 2 Scope (implemented)

- Added Firebase bootstrap in app startup (`Firebase.initializeApp()` with safe fallback)
- Added authentication module:
  - `AuthRepository`
  - `AuthBloc`
  - auth session model
- Added profile module:
  - `ProfileRepository`
  - `ProfileBloc`
  - profile domain model
- Implemented backend profile onboarding flow:
  - `GET /api/v1/users/me`
  - if `404` -> `POST /api/v1/users/me`
- Added fallback for local backend without Firebase auth:
  - `GET /api/v1/users`
  - if empty -> `POST /api/v1/users`
- Added Home tab auth UI:
  - email/password sign-in
  - anonymous sign-in
  - manual token fallback
  - sign-out
- Added profile sync card showing QR and points

## Part 3 Scope (implemented)

- Added events action module:
  - `EventActionRepository`
  - `EventCheckInBloc`
  - event check-in result model
- Added Event details screen with quick actions:
  - Show My QR
  - Admin check-in
- Added My QR screen using backend profile QR (`qr_flutter`)
- Added admin scanner screen (`mobile_scanner`) + manual QR input fallback
- Connected admin check-in endpoint:
  - `POST /api/v1/events/{eventId}/check-ins`
- Added required camera permissions:
  - Android `CAMERA` in `AndroidManifest.xml`
  - iOS `NSCameraUsageDescription` in `Info.plist`

## Stack

- Flutter: SDK from `android/local.properties` (recommended `3.41.x`)
- Dart: version bundled with selected Flutter SDK
- State management: `flutter_bloc`
- Networking: `dio`
- Routing: `go_router`
- Auth: `firebase_auth`
- QR: `qr_flutter`
- Scanner: `mobile_scanner`

## Run

1. Install dependencies:

```bash
scripts\flutterw.cmd pub get
```

2. Start app with backend URL:

```bash
scripts\flutterw.cmd run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

3. Optional cleanup when switching Flutter SDK:

```bash
scripts\flutterw.cmd clean
scripts\flutterw.cmd pub get
```

Notes:
- For Android emulator use `http://10.0.2.2:8080`
- For iOS simulator use `http://localhost:8080`
- For physical device use your machine LAN IP (example `http://192.168.1.20:8080`)

If `API_BASE_URL` is not provided, app uses:
- Android: `http://10.0.2.2:8080`
- Others: `http://localhost:8080`

### Firebase notes

- If Firebase files are missing (`google-services.json`, `GoogleService-Info.plist`), app still runs.
- In that case, Firebase login will be unavailable and Home screen shows the init error.
- You can still test protected backend endpoints by pasting a valid Firebase ID token in manual token fallback.

### Check-in notes

- In Firebase mode, event check-in endpoint is ADMIN-only in backend security.
- In local mode (`neverest.auth.provider=none`), check-in works without auth.

## Part 4 Scope (implemented)

- Added challenge action module:
  - `ChallengeActionRepository`
  - `ChallengeActionBloc`
  - challenge submission domain model
- Added reward action module:
  - `RewardActionRepository`
  - `RewardActionBloc`
  - reward redemption domain model
- Added challenge details screen:
  - submit challenge proof/metric
  - load my submissions
  - admin review mode (approve/reject submissions)
- Added reward details screen:
  - redeem reward
  - load my redemptions
  - show latest redemption code
- Wired write endpoints with fallback logic for both auth modes:
  - Challenges:
    - `POST /api/v1/challenges/{challengeId}/submissions/me`
    - fallback `POST /api/v1/challenges/{challengeId}/submissions`
    - `GET /api/v1/challenges/{challengeId}/submissions/me`
    - fallback `GET /api/v1/challenges/{challengeId}/submissions?userId=...`
    - admin review `POST /api/v1/challenges/{challengeId}/submissions/{submissionId}/review`
  - Rewards:
    - `POST /api/v1/rewards/{rewardId}/redeem/me`
    - fallback `POST /api/v1/rewards/{rewardId}/redeem`
    - `GET /api/v1/rewards/redemptions/me`
    - fallback `GET /api/v1/rewards/redemptions?userId=...`

## Next Step (implemented)

- Added real light/dark theming support with persistence (`ThemeModeCubit`)
- Added in-app theme toggle button in main app bar
- Finalized dark palette (`DarkTheme`) and upgraded Material 3 visual tokens
- Added shimmer loading skeletons for dashboard tab loading states
- Added smoother state transitions (`AnimatedSwitcher`) between loading/error/content
- Polished UI hierarchy across:
  - Home dashboard
  - Events/Challenges/Rewards/Leaderboard tabs
  - Event details/check-in, Challenge details, Reward details, My QR

## Next Step 2 (implemented)

- Added visual onboarding flow (3 slides) with persisted completion state
- Added launch gate that decides `Onboarding` vs `MainShell` on app start
- Added custom navigation transitions (`fade + slide`) for detail screens
- Added reusable illustrated state widget (`AppIllustratedState`)
- Replaced plain empty/error placeholders with illustrated states across:
  - Dashboard loading/error/empty handling
  - Events/Challenges/Rewards/Leaderboard empty states
  - Profile/QR sync and not-authenticated states
  - Challenge/Reward details empty state sections

## Backend Coverage (implemented)

The mobile app now covers the backend functional surface, including admin operations:

- Auth:
  - `GET /api/v1/auth/me`
- Users:
  - `GET /api/v1/users/me`
  - `POST /api/v1/users/me`
  - `GET /api/v1/users` (admin)
  - `POST /api/v1/users` (admin)
- Events:
  - `GET /api/v1/events`
  - `POST /api/v1/events` (admin)
  - `POST /api/v1/events/{eventId}/check-ins` (admin)
  - `POST /api/v1/events/{eventId}/announcements/retry` (admin)
- Challenges:
  - `GET /api/v1/challenges`
  - `POST /api/v1/challenges` (admin)
  - `POST /api/v1/challenges/{challengeId}/submissions/me`
  - fallback `POST /api/v1/challenges/{challengeId}/submissions`
  - `GET /api/v1/challenges/{challengeId}/submissions/me`
  - fallback `GET /api/v1/challenges/{challengeId}/submissions?userId=...`
  - `POST /api/v1/challenges/{challengeId}/submissions/{submissionId}/review` (admin)
- Rewards:
  - `GET /api/v1/rewards`
  - `POST /api/v1/rewards` (admin)
  - `POST /api/v1/rewards/{rewardId}/redeem/me`
  - fallback `POST /api/v1/rewards/{rewardId}/redeem`
  - `GET /api/v1/rewards/redemptions/me`
  - fallback `GET /api/v1/rewards/redemptions?userId=...`
- Leaderboard:
  - `GET /api/v1/leaderboard/general`
  - `GET /api/v1/leaderboard/activity/{activityType}`
- Admin logs:
  - `GET /api/v1/admin/audit-logs`

## Hardening + Release Prep (implemented)

- Added runtime access profiling layer:
  - `AccessRepository`
  - `AccessCubit`
  - access domain model
- Added visible role/access card in Home tab:
  - subject
  - authenticated status
  - authorities
  - computed `ADMIN ACCESS` vs `USER ACCESS`
- Added role-based admin entry gating in app shell:
  - Admin Center button is shown only when backend confirms admin access
  - Event admin check-in and challenge review mode are visible only for admin access
  - Admin Center screen self-guards and blocks access if role is missing
- Added global session hardening for protected API calls:
  - API interceptor publishes `401/403` auth failure events
  - `401` triggers automatic sign-out and re-auth prompt
  - `403` keeps session but shows a clear permission feedback message
  - on session invalidation, app returns to Home tab and clears dashboard cache
  - capability-check calls can opt out from global failure handling
- Hardened backend status ping:
  - `/hello` is consumed as optional health info (no longer blocks dashboard load)
  - backend now exposes `/hello` explicitly via `HelloController`
- Added release/demo operational docs:
  - `docs/MOBILE_RELEASE_CHECKLIST.md`
  - `docs/MOBILE_DEMO_CHECKLIST.md`

## Verify

```bash
scripts\flutterw.cmd analyze
scripts\flutterw.cmd build apk --debug
```

## Project Areas (new)

- `lib/app/`:
  - App bootstrap
  - Router
  - API and token services
- `lib/features/dashboard/`:
  - Dashboard repository
  - DTO-style models
  - Dashboard BLoC
- `lib/features/shell/`:
  - Main shell
  - Tab screens bound to dashboard state
- `lib/features/auth/`:
  - Auth repository + AuthBloc
- `lib/features/profile/`:
  - Profile repository + ProfileBloc
