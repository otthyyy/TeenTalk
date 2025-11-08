# Firebase Flutter App

A Flutter application with comprehensive Firebase integration, including Authentication, Firestore, Storage, Cloud Functions, Analytics, and Cloud Messaging.

## Features

- 🔐 **Authentication**: Email/password and anonymous authentication
- 📊 **Firestore**: NoSQL database with real-time capabilities
- 📁 **Storage**: File upload/download with progress tracking
- ⚡ **Cloud Functions**: Serverless backend functions
- 📈 **Analytics**: User behavior tracking
- 🔔 **Cloud Messaging**: Push notifications
- 🌍 **Environment Management**: Development and production flavors
- 🧪 **Built-in Testing**: Comprehensive Firebase service test suite

## Quick Start

### Prerequisites

- Flutter SDK (>=3.13.0)
- Firebase account
- Android Studio / Xcode

### Setup

1. **Clone and install dependencies**:
   ```bash
   git clone <repository>
   cd firebase_app
   flutter pub get
   ```

2. **Configure Firebase**:
   - Follow the [Firebase Setup Guide](FIREBASE_SETUP.md)
   - Create Firebase project and enable services
   - Download configuration files
   - Set up environment variables

3. **Run the app**:
   ```bash
   flutter run
   ```

4. **Test Firebase services**:
   - Navigate to the "Firebase Test" tab
   - Click "Run Firebase Tests" to verify setup

## Project Structure

```
lib/
├── core/                  # Core application setup
│   ├── app_config.dart    # Environment configuration
│   └── firebase_bootstrap.dart  # Firebase initialization
├── services/              # Firebase service abstractions
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── storage_service.dart
│   └── functions_service.dart
├── utils/                 # Utilities and helpers
│   ├── error_handler.dart
│   └── logger.dart
├── widgets/               # Reusable UI components
│   └── app_wrapper.dart
└── screens/               # Application screens
    ├── auth_screen.dart
    ├── home_screen.dart
    └── test_screen.dart
```

## Architecture

This application follows a clean architecture pattern with:

- **Service Layer**: Abstracts Firebase operations with error handling
- **Bootstrap Layer**: Handles Firebase initialization and configuration
- **UI Layer**: Flutter widgets with Provider state management
- **Environment Management**: Support for multiple deployment environments

## Environment Configuration

The app supports multiple environments through `.env` files:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef

# Environment
FLUTTER_ENV=dev
```

Copy `.env.example` to `.env` and update with your Firebase configuration.

## Firebase Services

### Authentication

- Email/password authentication
- Anonymous authentication
- User session management
- Password reset functionality

### Firestore

- Document CRUD operations
- Real-time listeners
- Batch operations
- Query builders

### Storage

- File upload/download
- Progress tracking
- Directory management
- URL generation

### Cloud Functions

- Callable functions
- Error handling
- Timeout management
- Region support

### Analytics & Messaging

- Automatic event tracking
- FCM token management
- Push notification setup

## Testing

The app includes a comprehensive test screen to verify all Firebase services:

1. Authentication status verification
2. Firestore connectivity and operations
3. Storage upload/download functionality
4. Cloud Functions availability
5. FCM token retrieval

## Documentation

- [Firebase Setup Guide](FIREBASE_SETUP.md) - Comprehensive setup instructions
- [API Documentation](lib/services/) - Service layer documentation

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly with the built-in test suite
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions or issues:

1. Check the [Firebase Setup Guide](FIREBASE_SETUP.md)
2. Run the built-in test suite
3. Review console logs
4. Consult Firebase documentation