import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/connectivity_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/verify_otp_screen.dart';
import 'screens/dashboards/student_dashboard.dart';
import 'screens/dashboards/professor_dashboard.dart';
import 'screens/dashboards/alumni_dashboard.dart';
import 'screens/dashboards/management_dashboard.dart';
import 'utils/app_theme.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API service
  ApiService.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const SmartAssessmentApp());
}

class SmartAssessmentApp extends StatelessWidget {
  const SmartAssessmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, child) {
          return MaterialApp(
            title: 'Smart Assessment System',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: _getInitialScreen(authProvider),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/verify-otp': (context) => const VerifyOTPScreen(email: ''),
              '/student': (context) => const StudentDashboard(),
              '/professor': (context) => const ProfessorDashboard(),
              '/alumni': (context) => const AlumniDashboard(),
              '/management': (context) => const ManagementDashboard(),
            },
          );
        },
      ),
    );
  }

  Widget _getInitialScreen(AuthProvider authProvider) {
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    switch (authProvider.user?.role) {
      case 'STUDENT':
        return const StudentDashboard();
      case 'PROFESSOR':
        return const ProfessorDashboard();
      case 'ALUMNI':
        return const AlumniDashboard();
      case 'MANAGEMENT':
        return const ManagementDashboard();
      default:
        return const LoginScreen();
    }
  }
}