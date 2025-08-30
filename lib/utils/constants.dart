class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Android emulator localhost
  static const String baseUrlPhysical = 'http://192.168.1.100:8080/api'; // Replace with your IP
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  
  // App Info
  static const String appName = 'Smart Assessment System';
  static const String appVersion = '1.0.0';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int otpLength = 4;
  static const int otpExpiryMinutes = 5;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // College Email Domain
  static const String collegeEmailDomain = '@stjosephstechnology.ac.in';
  
  // Departments
  static const List<String> departments = [
    'Computer Science Engineering',
    'Information Technology',
    'Electronics and Communication',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electrical Engineering',
  ];
  
  // Assessment Domains
  static const List<String> assessmentDomains = [
    'Computer Science',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'History',
    'Geography'
  ];
  
  // Difficulty Levels
  static const List<String> difficultyLevels = ['Easy', 'Medium', 'Hard'];
  
  // Work Modes
  static const List<String> workModes = ['On-site', 'Remote', 'Hybrid'];
  
  // Experience Levels
  static const List<String> experienceLevels = ['Entry', 'Mid', 'Senior', 'Lead'];
  
  // Currencies
  static const List<String> currencies = ['INR', 'USD', 'EUR'];
}