import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/notification_bell.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final User? user;
  final List<Widget>? actions;

  const DashboardAppBar({
    super.key,
    required this.title,
    this.user,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: AppTheme.surfaceColor,
      foregroundColor: AppTheme.textPrimaryColor,
      elevation: 0,
      actions: [
        const NotificationBell(),
        const SizedBox(width: 8),
        
        // User Avatar
        GestureDetector(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryColor,
              backgroundImage: user?.profilePicture != null 
                  ? NetworkImage(user!.profilePicture!)
                  : null,
              child: user?.profilePicture == null 
                  ? Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}