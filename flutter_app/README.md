# Smart Assessment System - Flutter Mobile App

A comprehensive Flutter mobile application for the Smart Assessment and Feedback Monitoring System, designed for educational institutions.

## Features

### 🎓 Multi-Role Support
- **Students**: AI assessments, class tests, task management, alumni networking
- **Professors**: Assessment creation, student insights, research management
- **Alumni**: Profile management, job posting, event organization, mentoring
- **Management**: System oversight, alumni verification, event approval

### 📱 Mobile-First Design
- Native Android experience with Material Design 3
- Responsive layouts optimized for mobile screens
- Smooth animations and transitions
- Offline capability for core features

### 🔐 Secure Authentication
- JWT-based authentication
- OTP verification for email validation
- Secure token storage
- Role-based access control

### 🤖 AI-Powered Features
- AI assessment generation
- Intelligent chatbot assistance
- Personalized learning roadmaps
- Smart content recommendations

### 💼 Professional Networking
- Alumni directory with advanced search
- Mentoring request system
- Job board with comprehensive listings
- Event management and RSVP

### 📊 Analytics & Insights
- Student performance tracking
- Activity heatmaps
- Assessment analytics
- Progress monitoring

## Technical Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.10+
- **Language**: Dart 3.0+
- **State Management**: Provider
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences + FlutterSecureStorage

### Backend Integration
- **API**: RESTful APIs with Spring Boot
- **Database**: MongoDB
- **Authentication**: JWT tokens
- **File Upload**: Multipart form data
- **Real-time**: WebSocket support

### Key Dependencies
```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.1          # State management
  go_router: ^12.1.1        # Navigation
  dio: ^5.3.2               # HTTP client
  shared_preferences: ^2.2.2 # Local storage
  flutter_secure_storage: ^9.0.0 # Secure storage
  fl_chart: ^0.64.0         # Charts and graphs
  cached_network_image: ^3.3.0 # Image caching
  url_launcher: ^6.2.1      # External links
  file_picker: ^6.1.1       # File selection
  image_picker: ^1.0.4      # Image selection
  table_calendar: ^3.0.9    # Calendar widget
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── job.dart
│   ├── event.dart
│   └── assessment.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── theme_provider.dart
│   └── connectivity_provider.dart
├── screens/                  # UI screens
│   ├── auth/                 # Authentication screens
│   ├── dashboards/           # Role-based dashboards
│   └── features/             # Feature-specific screens
├── services/                 # API and business logic
│   └── api_service.dart
├── utils/                    # Utilities and constants
│   ├── constants.dart
│   └── app_theme.dart
└── widgets/                  # Reusable UI components
    ├── custom_text_field.dart
    ├── loading_button.dart
    └── dashboard_app_bar.dart
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.10 or higher
- Dart SDK 3.0 or higher
- Android Studio with Android SDK
- Java 17 or higher (for backend)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   - Update `lib/utils/constants.dart`
   - Set your backend server IP address in `baseUrlPhysical`
   - For Android emulator, use `10.0.2.2:8080`
   - For physical device, use your computer's IP address

4. **Run the backend server**
   ```bash
   cd ../alu_backend
   ./mvnw spring-boot:run
   ```

5. **Run the Flutter app**
   ```bash
   flutter run
   ```

### Building for Release

1. **Build APK**
   ```bash
   flutter build apk --release
   ```

2. **Build App Bundle (recommended for Play Store)**
   ```bash
   flutter build appbundle --release
   ```

3. **Install on device**
   ```bash
   flutter install
   ```

## Configuration

### Network Configuration
- **Development**: Uses `10.0.2.2:8080` for Android emulator
- **Production**: Update `baseUrlPhysical` with your server IP
- **HTTPS**: Configure SSL certificates for production

### Authentication
- JWT tokens stored securely using FlutterSecureStorage
- Automatic token refresh handling
- Session management with proper cleanup

### Permissions
The app requires the following permissions:
- **Internet**: API communication
- **Storage**: File uploads and downloads
- **Camera**: Profile picture capture
- **Notifications**: Push notifications

## Features Overview

### Student Dashboard
- **Profile Management**: Complete profile with skills, achievements
- **AI Assessments**: Generate and take AI-powered tests
- **Class Assessments**: Professor-assigned tests and quizzes
- **Task Management**: AI-generated learning roadmaps
- **Alumni Network**: Connect with alumni for mentoring
- **Job Board**: Browse and apply for opportunities
- **Events**: View and register for events
- **Chat**: AI assistant and peer communication

### Alumni Dashboard
- **Profile Management**: Professional profile with experience
- **Alumni Directory**: Network with fellow alumni
- **Job Posting**: Share opportunities with students
- **Event Organization**: Request and manage events
- **Mentoring**: Guide students and junior alumni
- **Networking**: Professional connections

### Professor Dashboard
- **Assessment Creation**: Design custom tests and quizzes
- **Student Analytics**: Performance insights and tracking
- **Research Management**: Publications and projects
- **Event Participation**: Academic events and seminars
- **Communication**: Student and peer interaction

### Management Dashboard
- **System Overview**: Comprehensive analytics
- **Alumni Verification**: Approve alumni registrations
- **Event Management**: Review and approve events
- **User Management**: Oversee all system users
- **Reports**: Generate system-wide reports

## API Integration

### Authentication Endpoints
- `POST /auth/signin` - User login
- `POST /auth/signup` - User registration
- `POST /auth/verify-otp` - Email verification
- `POST /auth/change-password` - Password update

### Core Features
- **Jobs**: CRUD operations for job postings
- **Events**: Event management and RSVP
- **Assessments**: AI generation and submission
- **Alumni**: Directory and networking
- **Chat**: Messaging and AI assistance

### Error Handling
- Network connectivity monitoring
- Graceful error messages
- Retry mechanisms for failed requests
- Offline mode for cached data

## Security

### Data Protection
- Secure token storage using FlutterSecureStorage
- Input validation and sanitization
- HTTPS communication (production)
- Biometric authentication support (future)

### Privacy
- Minimal data collection
- User consent for data sharing
- Secure file handling
- Privacy-compliant analytics

## Performance

### Optimization
- Image caching and compression
- Lazy loading for large lists
- Efficient state management
- Memory leak prevention

### Monitoring
- Performance metrics tracking
- Crash reporting integration
- User analytics (privacy-compliant)
- API response time monitoring

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

## Deployment

### Play Store Release
1. Configure app signing
2. Update version in `pubspec.yaml`
3. Build app bundle: `flutter build appbundle --release`
4. Upload to Play Console
5. Complete store listing

### Internal Distribution
1. Build APK: `flutter build apk --release`
2. Distribute via Firebase App Distribution
3. Or share APK file directly

## Support

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Material Design 3](https://m3.material.io/)
- [Provider State Management](https://pub.dev/packages/provider)

### Troubleshooting
- Check network connectivity
- Verify backend server is running
- Update Flutter SDK if needed
- Clear app data for fresh start

### Contact
- **Email**: support@stjosephstechnology.ac.in
- **Phone**: +91 98765 43210
- **Office Hours**: 9:00 AM - 5:00 PM (Mon-Fri)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Changelog

### Version 1.0.0
- Initial release
- Complete feature parity with web application
- Material Design 3 implementation
- Comprehensive testing suite
- Production-ready build configuration