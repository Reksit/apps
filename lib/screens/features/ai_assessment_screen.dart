import 'package:flutter/material.dart';

import '../../models/assessment.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/loading_button.dart';

class AIAssessmentScreen extends StatefulWidget {
  const AIAssessmentScreen({super.key});

  @override
  State<AIAssessmentScreen> createState() => _AIAssessmentScreenState();
}

class _AIAssessmentScreenState extends State<AIAssessmentScreen> {
  Assessment? _assessment;
  bool _loading = false;
  bool _isActive = false;
  int _currentQuestion = 0;
  List<int> _answers = [];
  int _timeLeft = 0;
  DateTime? _startedAt;
  AssessmentResult? _results;
  bool _showResults = false;

  // Configuration
  String _selectedDomain = '';
  String _selectedDifficulty = '';
  int _numberOfQuestions = 5;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _generateAssessment() async {
    if (_selectedDomain.isEmpty || _selectedDifficulty.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select domain and difficulty'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final assessment = await ApiService.generateAIAssessment({
        'domain': _selectedDomain,
        'difficulty': _selectedDifficulty,
        'numberOfQuestions': _numberOfQuestions,
      });
      
      setState(() {
        _assessment = assessment;
        _answers = List.filled(assessment.questions.length, -1);
        _currentQuestion = 0;
        _showResults = false;
        _results = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assessment generated successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate assessment: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void _startAssessment() {
    if (_assessment == null) return;
    
    setState(() {
      _isActive = true;
      _timeLeft = _assessment!.duration * 60; // Convert to seconds
      _startedAt = DateTime.now();
    });
    
    // Start timer
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isActive && _timeLeft > 0) {
        setState(() => _timeLeft--);
        _startTimer();
      } else if (_timeLeft <= 0) {
        _submitAssessment();
      }
    });
  }

  Future<void> _submitAssessment() async {
    if (_assessment == null || _startedAt == null) return;

    setState(() => _isActive = false);
    
    try {
      final submission = {
        'answers': _answers.asMap().entries.map((entry) => {
          'questionIndex': entry.key,
          'selectedAnswer': entry.value,
        }).toList(),
        'startedAt': _startedAt!.toIso8601String(),
      };

      final result = await ApiService.submitAssessment(_assessment!.id, submission);
      
      setState(() {
        _results = result;
        _showResults = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Assessment completed! Score: ${result.score}/${result.totalMarks}'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit assessment: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults && _results != null) {
      return _buildResultsView();
    }

    if (_assessment != null && _isActive) {
      return _buildAssessmentView();
    }

    if (_assessment != null && !_isActive) {
      return _buildAssessmentPreview();
    }

    return _buildConfigurationView();
  }

  Widget _buildConfigurationView() {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assessment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryLightColor],
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
                      const Icon(Icons.psychology, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AI Assessment Generator',
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
                    'Generate personalized assessments powered by AI to test your knowledge and skills.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Configuration Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Assessment Configuration',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    CustomDropdown<String>(
                      label: 'Domain',
                      value: _selectedDomain.isEmpty ? null : _selectedDomain,
                      items: AppConstants.assessmentDomains.map((domain) => 
                        DropdownMenuItem(value: domain, child: Text(domain))
                      ).toList(),
                      onChanged: (value) {
                        setState(() => _selectedDomain = value ?? '');
                      },
                      hint: 'Select a domain',
                    ),
                    const SizedBox(height: 16),
                    
                    CustomDropdown<String>(
                      label: 'Difficulty',
                      value: _selectedDifficulty.isEmpty ? null : _selectedDifficulty,
                      items: AppConstants.difficultyLevels.map((difficulty) => 
                        DropdownMenuItem(value: difficulty, child: Text(difficulty))
                      ).toList(),
                      onChanged: (value) {
                        setState(() => _selectedDifficulty = value ?? '');
                      },
                      hint: 'Select difficulty level',
                    ),
                    const SizedBox(height: 16),
                    
                    CustomDropdown<int>(
                      label: 'Number of Questions',
                      value: _numberOfQuestions,
                      items: [5, 10, 15, 20].map((count) => 
                        DropdownMenuItem(value: count, child: Text('$count Questions'))
                      ).toList(),
                      onChanged: (value) {
                        setState(() => _numberOfQuestions = value ?? 5);
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    LoadingButton(
                      onPressed: _generateAssessment,
                      isLoading: _loading,
                      text: 'Generate Assessment',
                      icon: Icons.auto_awesome,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentPreview() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _assessment = null;
            });
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _assessment!.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _assessment!.difficulty ?? 'Medium',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      _assessment!.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            Icons.quiz,
                            'Questions',
                            '${_assessment!.questions.length}',
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            Icons.timer,
                            'Duration',
                            '${_assessment!.duration} min',
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            Icons.star,
                            'Total Marks',
                            '${_assessment!.totalMarks}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    LoadingButton(
                      onPressed: _startAssessment,
                      isLoading: false,
                      text: 'Start Assessment',
                      icon: Icons.play_arrow,
                      backgroundColor: AppTheme.successColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentView() {
    final question = _assessment!.questions[_currentQuestion];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentQuestion + 1}/${_assessment!.questions.length}'),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppTheme.errorColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_timeLeft),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / _assessment!.questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.question,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Options
                          ...question.options.asMap().entries.map((entry) {
                            final index = entry.key;
                            final option = entry.value;
                            final isSelected = _answers[_currentQuestion] == index;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _answers[_currentQuestion] = index;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected 
                                          ? AppTheme.primaryColor 
                                          : Colors.grey[300]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: isSelected 
                                        ? AppTheme.primaryColor.withOpacity(0.1) 
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                              ? AppTheme.primaryColor 
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected 
                                                ? AppTheme.primaryColor 
                                                : Colors.grey[400]!,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: isSelected 
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${String.fromCharCode(65 + index)}. $option',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Navigation
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentQuestion > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _currentQuestion--);
                      },
                      child: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentQuestion < _assessment!.questions.length - 1) {
                        setState(() => _currentQuestion++);
                      } else {
                        _submitAssessment();
                      }
                    },
                    child: Text(
                      _currentQuestion < _assessment!.questions.length - 1 
                          ? 'Next' 
                          : 'Submit',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentPreview() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() => _assessment = null);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _assessment!.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _assessment!.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            Icons.quiz,
                            'Questions',
                            '${_assessment!.questions.length}',
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            Icons.timer,
                            'Duration',
                            '${_assessment!.duration} min',
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            Icons.star,
                            'Total Marks',
                            '${_assessment!.totalMarks}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    LoadingButton(
                      onPressed: _startAssessment,
                      isLoading: false,
                      text: 'Start Assessment',
                      icon: Icons.play_arrow,
                      backgroundColor: AppTheme.successColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Results'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Results Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 64,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Assessment Completed!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here\'s your performance summary',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Score Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildResultStat(
                            'Score',
                            '${_results!.score}/${_results!.totalMarks}',
                            AppTheme.primaryColor,
                          ),
                        ),
                        Expanded(
                          child: _buildResultStat(
                            'Percentage',
                            '${_results!.percentage.toStringAsFixed(1)}%',
                            AppTheme.successColor,
                          ),
                        ),
                        Expanded(
                          child: _buildResultStat(
                            'Grade',
                            _results!.grade,
                            AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Back Button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _assessment = null;
                  _showResults = false;
                  _results = null;
                });
              },
              child: const Text('Take Another Assessment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}