import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/app_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _classController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _batchController = TextEditingController();
  final _companyController = TextEditingController();
  
  String _selectedRole = 'student';
  String _selectedDepartment = '';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _classController.dispose();
    _graduationYearController.dispose();
    _batchController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final userData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phoneNumber': _phoneController.text,
      'department': _selectedDepartment,
      'role': _selectedRole,
    };

    // Add role-specific fields
    if (_selectedRole != 'alumni') {
      userData['password'] = _passwordController.text;
    }

    if (_selectedRole == 'student') {
      userData['className'] = _classController.text;
    }

    if (_selectedRole == 'alumni') {
      userData['graduationYear'] = _graduationYearController.text;
      userData['batch'] = _batchController.text;
      userData['placedCompany'] = _companyController.text;
    }

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.register(userData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        if (_selectedRole == 'alumni') {
          context.go('/login');
        } else {
          context.go('/verify-otp', extra: _emailController.text);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo and Title
                const AppLogo(size: 80),
                const SizedBox(height: 24),
                
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Join the smart assessment platform',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Role Selection
                CustomDropdown(
                  label: 'Role',
                  value: _selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Student')),
                    DropdownMenuItem(value: 'professor', child: Text('Professor')),
                    DropdownMenuItem(value: 'alumni', child: Text('Alumni')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Name Field
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Email Field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: _selectedRole == 'alumni' 
                      ? 'Enter your email' 
                      : 'Enter your college email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (_selectedRole != 'alumni' && 
                        !value.endsWith(AppConstants.collegeEmailDomain)) {
                      return 'Please use your college email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password Field (not for alumni)
                if (_selectedRole != 'alumni') ...[
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Create a password (min 6 characters)',
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < AppConstants.minPasswordLength) {
                        return 'Password must be at least ${AppConstants.minPasswordLength} characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Phone Field
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Department Field
                CustomDropdown(
                  label: 'Department',
                  value: _selectedDepartment,
                  items: AppConstants.departments.map((dept) => 
                    DropdownMenuItem(value: dept, child: Text(dept))
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a department';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Role-specific fields
                if (_selectedRole == 'student') ...[
                  CustomDropdown(
                    label: 'Class',
                    value: _classController.text,
                    items: const ['I', 'II', 'III', 'IV'].map((cls) => 
                      DropdownMenuItem(value: cls, child: Text(cls))
                    ).toList(),
                    onChanged: (value) {
                      _classController.text = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a class';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                if (_selectedRole == 'alumni') ...[
                  CustomDropdown(
                    label: 'Graduation Year',
                    value: _graduationYearController.text,
                    items: List.generate(10, (index) => (2018 + index).toString())
                        .map((year) => DropdownMenuItem(value: year, child: Text(year)))
                        .toList(),
                    onChanged: (value) {
                      _graduationYearController.text = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select graduation year';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  CustomDropdown(
                    label: 'Batch',
                    value: _batchController.text,
                    items: const ['A', 'B', 'C'].map((batch) => 
                      DropdownMenuItem(value: batch, child: Text(batch))
                    ).toList(),
                    onChanged: (value) {
                      _batchController.text = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a batch';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    controller: _companyController,
                    label: 'Current Company',
                    hint: 'Enter your current company name',
                    prefixIcon: Icons.business_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your company name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                const SizedBox(height: 24),
                
                // Register Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return LoadingButton(
                      onPressed: _handleRegister,
                      isLoading: authProvider.isLoading,
                      text: 'Create Account',
                      icon: Icons.person_add,
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}