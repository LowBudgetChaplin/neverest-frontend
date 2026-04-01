# Mobile Demo Checklist

## User Flow

1. Open app -> onboarding -> main shell
2. Sign in (or manual token fallback)
3. Home:
   - backend status
   - auth/profile/access cards
4. Events:
   - open event details
   - show My QR
5. Challenges:
   - submit challenge proof
   - view own submissions
6. Rewards:
   - redeem reward
   - show latest redemption code + history
7. Leaderboard:
   - general leaderboard
   - activity leaderboard tabs

## Admin Flow

1. Confirm Admin Center button appears for admin-access sessions
2. Create user
3. Create event
4. Retry event announcements
5. Create challenge
6. Create reward
7. View and filter audit logs

## Edge Cases

- Empty states render properly
- Error states show actionable retry buttons
- Dark/light mode toggle works
- Dashboard refresh works while preserving UI state
- Session invalidation:
  - force an invalid token and verify automatic sign-out on first `401`
  - verify `403` shows a permission message without logging out
