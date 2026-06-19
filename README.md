# Shresht Library Student App

Flutter Android app for Shresht Library students.

## Run

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Use `http://127.0.0.1:8000/api/v1` for desktop/web-style local clients and `http://10.0.2.2:8000/api/v1` for the Android emulator.

## Covered User APIs

- Auth, OTP, forgot/reset password, logout
- Dashboard, profile, profile photo, ID card, referrals
- QR attendance, attendance logs, holidays
- Membership plans/history, manual UPI/payment initiation, payment history
- Seats and seat assignment history
- Study goal and study sessions
- Notifications list/read and device token registration API method
- Library info, facilities, achievers, reviews, review summary, review submit
