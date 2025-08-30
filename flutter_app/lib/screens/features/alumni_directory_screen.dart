import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class AlumniDirectoryScreen extends StatefulWidget {
  const AlumniDirectoryScreen({super.key});

  @override
  State<AlumniDirectoryScreen> createState() => _AlumniDirectoryScreenState();
}

class _AlumniDirectoryScreenState extends State<AlumniDirectoryScreen> {
  List<Map<String, dynamic>> _alumni = [];
  List<Map<String, dynamic>> _filteredAlumni = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  String _selectedDepartment = '';
  String _selectedYear = '';

  @override
  void initState() {
    super.initState();
    _loadAlumni();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAlumni() async {
    try {
      setState(() => _loading = true);
      final alumni = await ApiService.getAlumniDirectory();
      setState(() {
        _alumni = alumni;
        _filteredAlumni = alumni;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load alumni: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void _filterAlumni() {
    setState(() {
      _filteredAlumni = _alumni.where((alumni) {
        final matchesSearch = _searchController.text.isEmpty ||
            alumni['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
            alumni['email'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
            (alumni['currentCompany']?.toString().toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
        
        final matchesDepartment = _selectedDepartment.isEmpty ||
            alumni['department'] == _selectedDepartment;
        
        final matchesYear = _selectedYear.isEmpty ||
            alumni['graduationYear'].toString() == _selectedYear;
        
        return matchesSearch && matchesDepartment && matchesYear;
      }).toList();
    });
  }

  Future<void> _sendMentoringRequest(String alumniId, String alumniName) async {
    try {
      await ApiService.sendConnectionRequest(
        alumniId,
        'Hi $alumniName, I would like to connect with you for mentoring and career guidance. Thank you!',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mentoring request sent successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final departments = _alumni.map((a) => a['department'].toString()).toSet().toList();
    final years = _alumni.map((a) => a['graduationYear'].toString()).toSet().toList()..sort();

    return Scaffold(
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search alumni...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => _filterAlumni(),
                ),
                const SizedBox(height: 12),
                
                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDepartment.isEmpty ? null : _selectedDepartment,
                        decoration: InputDecoration(
                          labelText: 'Department',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(value: '', child: Text('All Departments')),
                          ...departments.map((dept) => DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedDepartment = value ?? '');
                          _filterAlumni();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedYear.isEmpty ? null : _selectedYear,
                        decoration: InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(value: '', child: Text('All Years')),
                          ...years.map((year) => DropdownMenuItem(
                            value: year,
                            child: Text('Class of $year'),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedYear = value ?? '');
                          _filterAlumni();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Showing ${_filteredAlumni.length} of ${_alumni.length} alumni',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Alumni List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAlumni.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No alumni found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            Text(
                              'Try adjusting your search criteria',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAlumni,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredAlumni.length,
                          itemBuilder: (context, index) {
                            final alumni = _filteredAlumni[index];
                            return _buildAlumniCard(alumni, user);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlumniCard(Map<String, dynamic> alumni, User? user) {
    final isAvailableForMentorship = alumni['isAvailableForMentorship'] ?? false;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.secondaryColor,
                  child: Text(
                    alumni['name'].toString().substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alumni['name'] ?? 'Unknown',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (alumni['currentCompany'] != null) ...[
                        Text(
                          alumni['currentCompany'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                      Text(
                        alumni['email'] ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Details
            Row(
              children: [
                Icon(Icons.school, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text('${alumni['department']} • Class of ${alumni['graduationYear']}'),
              ],
            ),
            
            if (alumni['location'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(alumni['location']),
                ],
              ),
            ],
            
            if (isAvailableForMentorship) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, size: 16, color: AppTheme.successColor),
                    const SizedBox(width: 4),
                    Text(
                      'Available for Mentorship',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Skills
            if (alumni['skills'] != null && (alumni['skills'] as List).isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: (alumni['skills'] as List).take(3).map((skill) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    skill.toString(),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to profile
                    },
                    icon: const Icon(Icons.person, size: 16),
                    label: const Text('View Profile'),
                  ),
                ),
                const SizedBox(width: 12),
                if (isAvailableForMentorship && user?.role != 'ALUMNI') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _sendMentoringRequest(
                        alumni['id'],
                        alumni['name'],
                      ),
                      icon: const Icon(Icons.school, size: 16),
                      label: const Text('Request Mentoring'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}