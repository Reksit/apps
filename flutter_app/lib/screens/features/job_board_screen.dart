import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/job.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  List<Job> _jobs = [];
  List<Job> _filteredJobs = [];
  bool _loading = true;
  bool _showCreateForm = false;
  String _searchQuery = '';
  String _selectedJobType = '';
  String _selectedLocation = '';

  // Form controllers
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _applicationUrlController = TextEditingController();
  
  JobType _selectedType = JobType.fullTime;
  String _selectedWorkMode = 'On-site';
  String _selectedCurrency = 'INR';
  List<String> _requirements = [''];
  List<String> _benefits = [''];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _descriptionController.dispose();
    _contactEmailController.dispose();
    _applicationUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    try {
      setState(() => _loading = true);
      final jobs = await ApiService.getAllJobs();
      setState(() {
        _jobs = jobs;
        _filteredJobs = jobs;
      });
      _filterJobs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load jobs: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void _filterJobs() {
    setState(() {
      _filteredJobs = _jobs.where((job) {
        final matchesSearch = _searchQuery.isEmpty ||
            job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job.location.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesType = _selectedJobType.isEmpty ||
            job.type.name == _selectedJobType;
        
        final matchesLocation = _selectedLocation.isEmpty ||
            job.location.toLowerCase().contains(_selectedLocation.toLowerCase());
        
        return matchesSearch && matchesType && matchesLocation;
      }).toList();
    });
  }

  Future<void> _createJob() async {
    if (!_validateForm()) return;

    try {
      final jobData = {
        'title': _titleController.text,
        'company': _companyController.text,
        'location': _locationController.text,
        'workMode': _selectedWorkMode,
        'type': _selectedType.name.toUpperCase(),
        'salaryMin': _salaryMinController.text,
        'salaryMax': _salaryMaxController.text,
        'currency': _selectedCurrency,
        'description': _descriptionController.text,
        'requirements': _requirements.where((req) => req.trim().isNotEmpty).toList(),
        'benefits': _benefits.where((ben) => ben.trim().isNotEmpty).toList(),
        'contactEmail': _contactEmailController.text,
        'applicationUrl': _applicationUrlController.text,
      };

      await ApiService.createJob(jobData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _resetForm();
        setState(() => _showCreateForm = false);
        _loadJobs();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post job: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  bool _validateForm() {
    if (_titleController.text.trim().isEmpty) {
      _showError('Please enter job title');
      return false;
    }
    if (_companyController.text.trim().isEmpty) {
      _showError('Please enter company name');
      return false;
    }
    if (_locationController.text.trim().isEmpty) {
      _showError('Please enter location');
      return false;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showError('Please enter job description');
      return false;
    }
    if (_contactEmailController.text.trim().isEmpty) {
      _showError('Please enter contact email');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _resetForm() {
    _titleController.clear();
    _companyController.clear();
    _locationController.clear();
    _salaryMinController.clear();
    _salaryMaxController.clear();
    _descriptionController.clear();
    _contactEmailController.clear();
    _applicationUrlController.clear();
    _selectedType = JobType.fullTime;
    _selectedWorkMode = 'On-site';
    _selectedCurrency = 'INR';
    _requirements = [''];
    _benefits = [''];
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final canPostJobs = user?.role == 'ALUMNI';

    return Scaffold(
      body: Column(
        children: [
          // Header and Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search jobs...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _filterJobs();
                  },
                ),
                const SizedBox(height: 12),
                
                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedJobType.isEmpty ? null : _selectedJobType,
                        decoration: InputDecoration(
                          labelText: 'Job Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(value: '', child: Text('All Types')),
                          ...JobType.values.map((type) => DropdownMenuItem(
                            value: type.name,
                            child: Text(type.name),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedJobType = value ?? '');
                          _filterJobs();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _selectedLocation = value);
                          _filterJobs();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Jobs List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredJobs.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.work_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No jobs found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadJobs,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredJobs.length,
                          itemBuilder: (context, index) {
                            final job = _filteredJobs[index];
                            return _buildJobCard(job);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: canPostJobs
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _showCreateForm = true),
              icon: const Icon(Icons.add),
              label: const Text('Post Job'),
            )
          : null,
    );
  }

  Widget _buildJobCard(Job job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getJobTypeColor(job.type),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    job.jobTypeDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Details
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(job.location, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 16),
                if (job.workMode != null) ...[
                  Icon(Icons.work_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(job.workMode!, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ],
            ),
            const SizedBox(height: 8),
            
            if (job.salaryMin != null && job.salaryMax != null) ...[
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    job.salaryDisplay,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            // Description
            Text(
              job.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            // Skills
            if (job.skillsRequired != null && job.skillsRequired!.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: job.skillsRequired!.take(5).map((skill) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),
            ],
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Posted by ${job.postedByName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _formatDate(job.postedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _applyToJob(job),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: const Text('Apply Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getJobTypeColor(JobType type) {
    switch (type) {
      case JobType.fullTime:
        return AppTheme.successColor;
      case JobType.partTime:
        return AppTheme.warningColor;
      case JobType.internship:
        return AppTheme.primaryColor;
      case JobType.contract:
        return AppTheme.accentColor;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _applyToJob(Job job) async {
    if (job.applicationUrl != null && job.applicationUrl!.isNotEmpty) {
      await _launchUrl(job.applicationUrl!);
    } else {
      final emailUrl = 'mailto:${job.contactEmail ?? job.postedByEmail}'
          '?subject=Application for ${job.title}'
          '&body=Dear ${job.postedByName},%0D%0A%0D%0A'
          'I am interested in applying for the ${job.title} position at ${job.company}.%0D%0A%0D%0A'
          'Please find my resume attached.%0D%0A%0D%0A'
          'Thank you for your consideration.%0D%0A%0D%0A'
          'Best regards';
      await _launchUrl(emailUrl);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}