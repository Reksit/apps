import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../services/api_service.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;

  const UserProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isEditing = false;
  bool _loading = false;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _loadFullProfile();
  }

  Future<void> _loadFullProfile() async {
    try {
      setState(() => _loading = true);
      
      Map<String, dynamic> profileData;
      switch (widget.user.role) {
        case 'STUDENT':
          profileData = await ApiService.getStudentProfile(widget.user.id);
          break;
        case 'PROFESSOR':
          profileData = await ApiService.getProfessorProfile(widget.user.id);
          break;
        case 'ALUMNI':
          profileData = await ApiService.getAlumniProfile(widget.user.id);
          break;
        default:
          return;
      }
      
      setState(() {
        _currentUser = User.fromJson({...widget.user.toJson(), ...profileData});
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    try {
      setState(() => _loading = true);
      
      final authProvider = context.read<AuthProvider>();
      await authProvider.updateUserProfile(_currentUser.toJson());
      
      setState(() => _isEditing = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing) ...[
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
          ] else ...[
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    RoleColors.getRoleColor(_currentUser.role),
                    RoleColors.getRoleColor(_currentUser.role).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: _currentUser.profilePicture != null 
                        ? NetworkImage(_currentUser.profilePicture!)
                        : null,
                    child: _currentUser.profilePicture == null 
                        ? Text(
                            _currentUser.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUser.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentUser.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _currentUser.role,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Profile Information
            _buildProfileSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    switch (_currentUser.role) {
      case 'STUDENT':
        return _buildStudentProfile();
      case 'PROFESSOR':
        return _buildProfessorProfile();
      case 'ALUMNI':
        return _buildAlumniProfile();
      case 'MANAGEMENT':
        return _buildManagementProfile();
      default:
        return _buildBasicProfile();
    }
  }

  Widget _buildStudentProfile() {
    return Column(
      children: [
        _buildInfoCard('Academic Information', [
          _buildInfoRow('Student ID', _currentUser.studentId ?? 'Not specified'),
          _buildInfoRow('Department', _currentUser.department ?? 'Not specified'),
          _buildInfoRow('Class', _currentUser.className ?? 'Not specified'),
          _buildInfoRow('Course', _currentUser.course ?? 'Not specified'),
          _buildInfoRow('Year', _currentUser.year ?? 'Not specified'),
          _buildInfoRow('Semester', _currentUser.semester ?? 'Not specified'),
          _buildInfoRow('CGPA', _currentUser.cgpa?.toString() ?? 'Not specified'),
        ]),
        const SizedBox(height: 16),
        _buildContactCard(),
        const SizedBox(height: 16),
        _buildSocialLinksCard(),
        const SizedBox(height: 16),
        _buildSkillsCard(),
      ],
    );
  }

  Widget _buildProfessorProfile() {
    return Column(
      children: [
        _buildInfoCard('Professional Information', [
          _buildInfoRow('Employee ID', _currentUser.employeeId ?? 'Not specified'),
          _buildInfoRow('Designation', _currentUser.designation ?? 'Not specified'),
          _buildInfoRow('Department', _currentUser.department ?? 'Not specified'),
          _buildInfoRow('Experience', '${_currentUser.experience ?? 0} years'),
          _buildInfoRow('Publications', _currentUser.publications?.toString() ?? '0'),
          _buildInfoRow('Students Supervised', _currentUser.studentsSupervised?.toString() ?? '0'),
        ]),
        const SizedBox(height: 16),
        _buildContactCard(),
        const SizedBox(height: 16),
        _buildSubjectsCard(),
        const SizedBox(height: 16),
        _buildResearchCard(),
      ],
    );
  }

  Widget _buildAlumniProfile() {
    return Column(
      children: [
        _buildInfoCard('Alumni Information', [
          _buildInfoRow('Graduation Year', _currentUser.graduationYear?.toString() ?? 'Not specified'),
          _buildInfoRow('Department', _currentUser.department ?? 'Not specified'),
          _buildInfoRow('Current Company', _currentUser.currentCompany ?? 'Not specified'),
          _buildInfoRow('Current Position', _currentUser.currentPosition ?? 'Not specified'),
          _buildInfoRow('Work Experience', '${_currentUser.workExperience ?? 0} years'),
          _buildInfoRow('Mentorship Available', _currentUser.mentorshipAvailable == true ? 'Yes' : 'No'),
        ]),
        const SizedBox(height: 16),
        _buildContactCard(),
        const SizedBox(height: 16),
        _buildSocialLinksCard(),
        const SizedBox(height: 16),
        _buildSkillsCard(),
        const SizedBox(height: 16),
        _buildAchievementsCard(),
      ],
    );
  }

  Widget _buildManagementProfile() {
    return Column(
      children: [
        _buildInfoCard('Management Information', [
          _buildInfoRow('Department', _currentUser.department ?? 'Not specified'),
          _buildInfoRow('Designation', _currentUser.designation ?? 'Management'),
          _buildInfoRow('Employee ID', _currentUser.employeeId ?? 'Not specified'),
        ]),
        const SizedBox(height: 16),
        _buildContactCard(),
      ],
    );
  }

  Widget _buildBasicProfile() {
    return Column(
      children: [
        _buildContactCard(),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Email', _currentUser.email),
            _buildInfoRow('Phone', _currentUser.phoneNumber ?? 'Not specified'),
            _buildInfoRow('Location', _currentUser.location ?? 'Not specified'),
            if (_currentUser.bio != null && _currentUser.bio!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Bio',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _currentUser.bio!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinksCard() {
    if (_currentUser.linkedinUrl == null && 
        _currentUser.githubUrl == null && 
        _currentUser.portfolioUrl == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Social Links',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_currentUser.linkedinUrl != null && _currentUser.linkedinUrl!.isNotEmpty)
              _buildSocialLink('LinkedIn', _currentUser.linkedinUrl!, Icons.link),
            if (_currentUser.githubUrl != null && _currentUser.githubUrl!.isNotEmpty)
              _buildSocialLink('GitHub', _currentUser.githubUrl!, Icons.code),
            if (_currentUser.portfolioUrl != null && _currentUser.portfolioUrl!.isNotEmpty)
              _buildSocialLink('Portfolio', _currentUser.portfolioUrl!, Icons.web),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsCard() {
    if (_currentUser.skills == null || _currentUser.skills!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skills',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentUser.skills!.map((skill) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsCard() {
    if (_currentUser.achievements == null || _currentUser.achievements!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._currentUser.achievements!.map((achievement) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.star, color: AppTheme.warningColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      achievement,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsCard() {
    if (_currentUser.subjectsTeaching == null || _currentUser.subjectsTeaching!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subjects Teaching',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentUser.subjectsTeaching!.map((subject) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  subject,
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResearchCard() {
    if (_currentUser.researchInterests == null || _currentUser.researchInterests!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Research Interests',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentUser.researchInterests!.map((interest) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLink(String label, String url, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _launchUrl(url),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Icon(Icons.open_in_new, size: 16, color: AppTheme.textSecondaryColor),
          ],
        ),
      ),
    );
  }
}