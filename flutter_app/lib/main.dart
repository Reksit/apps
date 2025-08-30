import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
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
import 'screens/profile/user_profile_screen.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Smart Assessment System',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) => VerifyOTPScreen(
        email: state.extra as String? ?? '',
      ),
    ),
    GoRoute(
      path: '/student',
      builder: (context, state) => const StudentDashboard(),
    ),
    GoRoute(
      path: '/professor',
      builder: (context, state) => const ProfessorDashboard(),
    ),
    GoRoute(
      path: '/alumni',
      builder: (context, state) => const AlumniDashboard(),
    ),
    GoRoute(
      path: '/management',
      builder: (context, state) => const ManagementDashboard(),
    ),
    GoRoute(
      path: '/profile/:userId',
      builder: (context, state) => UserProfileScreen(
        userId: state.pathParameters['userId']!,
      ),
    ),
  ],
  redirect: (context, state) {
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isAuthenticated;
    final isLoggingIn = state.matchedLocation == '/login' || 
                       state.matchedLocation == '/register' || 
                       state.matchedLocation == '/verify-otp';

    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }
    
    if (isLoggedIn && isLoggingIn) {
      final user = authProvider.user;
      switch (user?.role) {
        case 'STUDENT':
          return '/student';
        case 'PROFESSOR':
          return '/professor';
        case 'ALUMNI':
          return '/alumni';
        case 'MANAGEMENT':
          return '/management';
        default:
          return '/login';
      }
    }
    
    return null;
  },
);