# Kado24 Consumer App

Flutter mobile application for consumers to browse and purchase digital vouchers.

## Features

- User registration and authentication
- Browse vouchers by category
- Search vouchers
- View voucher details
- Purchase vouchers
- Digital wallet with QR codes
- Order history
- Profile management

## Setup

```bash
# Install dependencies
flutter pub get

# Run on emulator/device
flutter run

# Build APK
flutter build apk

# Build iOS
flutter build ios
```

## Configuration

Update API URLs in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://YOUR_BACKEND_URL:8081';
```

For local testing:
- Android Emulator: `http://10.0.2.2:8081`
- iOS Simulator: `http://localhost:8081`
- Physical Device: `http://YOUR_COMPUTER_IP:8081`

## Backend Services

Connects to:
- Auth Service (8081)
- User Service (8082)
- Voucher Service (8083)
- Order Service (8084)
- Wallet Service (8086)

## Project Structure

```
lib/
├── main.dart
├── models/
├── services/
├── providers/
├── screens/
└── widgets/
```

## Status

**Current:** Basic structure and authentication implemented  
**Next:** Complete voucher browsing, checkout, and wallet screens






































