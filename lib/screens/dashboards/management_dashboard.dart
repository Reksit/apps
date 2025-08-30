import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/dashboard_app_bar.dart';
import '../../widgets/dashboard_drawer.dart';
import '../../widgets/feature_tile.dart';
import '../features/dashboard_stats_screen.dart';
import '../features/alumni_verification_screen.dart';
import '../features/event_management_screen.dart';
import '../features/student_heatmap_screen.dart';
import '../features/alumni_directory_screen.dart';
import '../features/job_board_screen.dart';
import '../features/user_chat_screen.dart';
import '../features/password_change_screen.dart';

class ManagementDashboard extends StatefulWidget {
  const ManagementDashboard({super.key});

  @override
  State<ManagementDashboard> createState() => _ManagementDashboardState();
}

class _ManagementDashboardState extends State<ManagementDashboard> {
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
        title: 'Management Dashboard',
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
                  colors: [AppTheme.accentColor, Color(0xFF8B5CF6)],
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
                      const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Management Portal',
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
                    'Monitor student performance, verify alumni, and oversee the entire assessment system.',
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
              'Management Features',
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
                  title: 'System Overview',
                  subtitle: 'Dashboard statistics',
                  icon: Icons.dashboard,
                  color: AppTheme.accentColor,
                  onTap: () => _navigateToFeature(const DashboardStatsScreen()),
                ),
                FeatureTile(
                  title: 'Alumni Verification',
                  subtitle: 'Approve alumni',
                  icon: Icons.verified_user,
                  color: AppTheme.warningColor,
                  badge: '5',
                  onTap: () => _navigateToFeature(const AlumniVerificationScreen()),
                ),
                FeatureTile(
                  title: 'Event Management',
                  subtitle: 'Approve events',
                  icon: Icons.event,
                  color: AppTheme.primaryColor,
                  onTap: () => _navigateToFeature(const EventManagementScreen()),
                ),
                FeatureTile(
                  title: 'Student Activity',
                  subtitle: 'Performance tracking',
                  icon: Icons.analytics,
                  color: AppTheme.successColor,
                  onTap: () => _navigateToFeature(const StudentHeatmapScreen()),
                ),
                FeatureTile(
                  title: 'Alumni Network',
                  subtitle: 'View alumni directory',
                  icon: Icons.people,
                  color: AppTheme.secondaryColor,
                  onTap: () => _navigateToFeature(const AlumniDirectoryScreen()),
                ),
                FeatureTile(
                  title: 'Job Portal',
                  subtitle: 'Monitor job posts',
                  icon: Icons.work,
                  color: AppTheme.primaryColor,
                  onTap: () => _navigateToFeature(const JobBoardScreen()),
                ),
                FeatureTile(
                  title: 'Communication',
                  subtitle: 'System messages',
                  icon: Icons.chat,
                  color: AppTheme.successColor,
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