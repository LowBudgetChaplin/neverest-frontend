# Mobile Release Checklist

## Firebase Client

- Add Android file: `android/app/google-services.json`
- Add iOS file: `ios/Runner/GoogleService-Info.plist`
- Confirm Firebase project matches backend `neverest.firebase.project-id`
- Confirm users have correct custom claims (`ROLE_ADMIN` for organizers)

## Backend Connectivity

- Verify app run command uses correct API URL:
  - Android emulator: `http://10.0.2.2:8080`
  - iOS simulator: `http://localhost:8080`
  - Device: LAN IP
- Verify `GET /hello` from app
- Verify authenticated flow with Firebase ID token

## Functional Smoke Tests

- Auth sign-in (email/password or anonymous)
- Profile auto onboarding (`/users/me`)
- Event check-in from scanner
- Challenge submit/review
- Reward redeem and redemption code visibility
- Admin center create operations and audit logs

## Build & Quality

- `flutter analyze`
- `flutter build apk --debug`
- (optional) `flutter build apk --release`
- (optional) `flutter build ios` on macOS

## Final Review

- Verify dark/light mode
- Verify onboarding flow and first-launch behavior
- Verify empty/error states are user-friendly
- Verify role-based admin button visibility
- Verify expired/invalid token triggers re-auth flow (auto sign-out on `401`)
