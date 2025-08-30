import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/dashboard_app_bar.dart';
import '../../widgets/dashboard_drawer.dart';
import '../../widgets/feature_tile.dart';
import '../features/alumni_profile_screen.dart';
import '../features/alumni_directory_screen.dart';
import '../features/job_board_screen.dart';
import '../features/events_screen.dart';
import '../features/alumni_event_request_screen.dart';
import '../features/user_chat_screen.dart';
import '../features/password_change_screen.dart';

class AlumniDashboard extends StatefulWidget {
  const AlumniDashboard({super.key});

  @override
  State<AlumniDashboard> createState() => _AlumniDashboardState();
}

class _AlumniDashboardState extends State<AlumniDashboard> {
  void _navigateToFeature(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      appBar: DashboardAppBar(
        title: 'Alumni Dashboard',
        user: user,
      ),
      drawer: DashboardDrawer(
        user: user,
        onPasswordChange: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PasswordChangeScreen()),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.secondaryColor, AppTheme.secondaryLightColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Welcome back, Alumni!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect with current students and fellow alumni. Share your experience, find opportunities, and give back to the community.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Features Grid
            Text(
              'Features',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                FeatureTile(
                  title: 'My Profile',
                  subtitle: 'Manage your profile',
                  icon: Icons.person,
                  color: AppTheme.secondaryColor,
                  onTap: () => _navigateToFeature(const AlumniProfileScreen()),
                ),
                FeatureTile(
                  title: 'Alumni Directory',
                  subtitle: 'Connect with alumni',
                  icon: Icons.people,
                  color: AppTheme.primaryColor,
                  onTap: () => _navigateToFeature(const AlumniDirectoryScreen()),
                ),
                FeatureTile(
                  title: 'Job Board',
                  subtitle: 'Post & view jobs',
                  icon: Icons.work,
                  color: AppTheme.accentColor,
                  onTap: () => _navigateToFeature(const JobBoardScreen()),
                ),
                FeatureTile(
                  title: 'Events',
                  subtitle: 'Campus events',
                  icon: Icons.event,
                  color: AppTheme.warningColor,
                  onTap: () => _navigateToFeature(const EventsScreen()),
                ),
                FeatureTile(
                  title: 'Request Event',
                  subtitle: 'Organize events',
                  icon: Icons.add_circle,
                  color: AppTheme.successColor,
                  onTap: () => _navigateToFeature(const AlumniEventRequestScreen()),
                ),
                FeatureTile(
                  title: 'Messages',
                  subtitle: 'Chat with community',
                  icon: Icons.chat,
                  color: AppTheme.primaryColor,
                  onTap: () => _navigateToFeature(const UserChatScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}