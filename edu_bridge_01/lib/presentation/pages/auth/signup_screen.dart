import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/role_selection_dialog.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_repository.dart';
import 'login_screen.dart';
import 'email_verification_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _childNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedUserType = AppConstants.student;
  bool _isDropdownOpen = false;
  List<Map<String, dynamic>> _students = [];
  bool _isLoadingStudents = false;

  Future<void> _loadStudents() async {
    if (!mounted) return;
    setState(() => _isLoadingStudents = true);
    try {
      final authRepository = RepositoryProvider.of<AuthRepository>(context);
      final students = await authRepository.getAllRegisteredStudents();
      print('Loaded ${students.length} students');
      if (!mounted) return;
      setState(() {
        _students = students;
        _isLoadingStudents = false;
      });
    } catch (e) {
      print('Error loading students: $e');
      if (!mounted) return;
      setState(() => _isLoadingStudents = false);
    }
  }

  void _showStudentSearchDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final authRepository = RepositoryProvider.of<AuthRepository>(context);
          
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              minHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.search, color: Colors.blue.shade600, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Find Your Student',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search students...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                searchController.clear();
                                setModalState(() {
                                  filteredStudents = List.from(_students);
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (query) {
                      setModalState(() {
                        if (query.isEmpty) {
                          filteredStudents = List.from(_students);
                        } else {
                          filteredStudents = _students.where((student) {
                            final name = student['name']?.toString().toLowerCase() ?? '';
                            final email = student['email']?.toString().toLowerCase() ?? '';
                            final studentClass = student['studentClass']?.toString().toLowerCase() ?? '';
                            final searchLower = query.toLowerCase();
                            return name.contains(searchLower) || 
                                   email.contains(searchLower) || 
                                   studentClass.contains(searchLower);
                          }).toList();
                        }
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Content
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: StreamBuilder<List<Map<String, dynamic>>>(
                                stream: authRepository.getStudentsStream(),
                                builder: (context, snapshot) {
                                  final studentCount = snapshot.data?.length ?? 0;
                                  final isLoading = snapshot.connectionState == ConnectionState.waiting;
                                  
                                  return Text(
                                    'Students (${isLoading ? 'Loading...' : '$studentCount available'})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                                    ),
                                  );
                                },
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showStudentNotFoundDialog();
                              },
                              child: const Text(
                                'Not found?',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: StreamBuilder<List<Map<String, dynamic>>>(
                            stream: authRepository.getStudentsStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              
                              if (snapshot.hasError) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      'Error loading students: ${snapshot.error}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                );
                              }
                              
                              final allStudents = snapshot.data ?? [];
                              final filteredStudents = searchController.text.isEmpty
                                  ? allStudents
                                  : allStudents.where((student) {
                                      final name = student['name']?.toString().toLowerCase() ?? '';
                                      final email = student['email']?.toString().toLowerCase() ?? '';
                                      final studentClass = student['studentClass']?.toString().toLowerCase() ?? '';
                                      final searchLower = searchController.text.toLowerCase();
                                      return name.contains(searchLower) || 
                                             email.contains(searchLower) || 
                                             studentClass.contains(searchLower);
                                    }).toList();
                              
                              if (allStudents.isEmpty) {
                                return _buildEmptySearchState(false);
                              }
                              
                              if (filteredStudents.isEmpty && searchController.text.isNotEmpty) {
                                return _buildEmptySearchState(true);
                              }
                              
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredStudents.length,
                                itemBuilder: (context, index) {
                                  final student = filteredStudents[index];
                                  return _buildStudentOption(student);
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentOption(Map<String, dynamic> student) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final studentName = student['name'] ?? 'Unknown';
    final studentEmail = student['email'] ?? '';
    final studentClass = student['studentClass'] ?? 'No class';
    
    return InkWell(
      onTap: () {
        _childNameController.text = studentName;
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  studentName.isNotEmpty ? studentName.substring(0, 1).toUpperCase() : 'S',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    studentName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (studentEmail.isNotEmpty)
                    Text(
                      studentEmail,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    studentClass,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptySearchState(bool isSearching) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.school_outlined,
              size: 48,
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              isSearching ? 'No students found' : 'No students yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearching 
                  ? 'Try different search terms'
                  : 'Students will appear once registered',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showStudentNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.orange),
            SizedBox(width: 12),
            Text('Student Not Found?'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('If you can\'t find your student, they may need to:'),
            SizedBox(height: 12),
            Text('• Register their account first'),
            Text('• Use the exact same name spelling'),
            Text('• Contact their teacher for assistance'),
            SizedBox(height: 16),
            Text(
              'You can still create your parent account and connect to your student later.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _childNameController.text = 'Student Name (To be verified)';
            },
            child: const Text('Continue Anyway'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Load students immediately
    _loadStudents();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _studentIdController.dispose();
    _employeeIdController.dispose();
    _childNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.blue.shade50,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 28, color: isDark ? Colors.white : Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              'EduBridge',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: isDark ? Colors.white : null,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            String displayMessage = state.message;
            bool shouldShowDialog = false;
            bool isStudentNotFound = false;
            String studentName = '';
            
            if (state.message.startsWith('SHOW_LOGIN_DIALOG:')) {
              displayMessage = state.message.substring('SHOW_LOGIN_DIALOG:'.length);
              shouldShowDialog = true;
            } else if (state.message.startsWith('STUDENT_NOT_FOUND:')) {
              studentName = state.message.substring('STUDENT_NOT_FOUND:'.length);
              isStudentNotFound = true;
            }
            
            if (!isStudentNotFound) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(displayMessage),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
            
            if (shouldShowDialog) {
              Future.delayed(const Duration(milliseconds: 800), () {
                if (mounted) {
                  showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    title: Row(
                      children: [
                        Icon(Icons.login, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 10),
                        const Text('Welcome Back!'),
                      ],
                    ),
                    content: const Text('You already have an account with this email. Would you like to login instead?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Stay Here'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                );
                }
              });
            } else if (isStudentNotFound) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  title: Row(
                    children: [
                      const Icon(Icons.person_search, color: Colors.orange),
                      const SizedBox(width: 10),
                      const Text('Student Not Found'),
                    ],
                  ),
                  content: Text(
                    'No student named "$studentName" is registered in our system. Would you like to register your student first?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Try Again'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Student registration coming soon!'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                      child: const Text('Register Student'),
                    ),
                  ],
                ),
              );
            }
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          } else if (state is AuthGoogleSignInNeedsRole) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => RoleSelectionDialog(
                onRoleSelected: (role) {
                  context.read<AuthBloc>().add(
                    CompleteGoogleSignInEvent(
                      uid: state.user.uid,
                      email: state.email,
                      name: state.name,
                      userType: role,
                    ),
                  );
                },
              ),
            );
          } else if (state is AuthEmailVerificationSent) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => EmailVerificationScreen(email: state.email),
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Main Content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),

                        // Create account text
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _getSignupTitle(),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: isDark ? Colors.white : null,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _getSignupSubtitle(),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDark ? const Color(0xFF94A3B8) : null,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // User type selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isDropdownOpen = !_isDropdownOpen;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade600,
                                      Colors.blue.shade400,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getUserTypeIcon(_selectedUserType),
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _selectedUserType,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: _isDropdownOpen ? 0.5 : 0.0,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        child: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Full name field
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: AppConstants.fullName,
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            if (value.length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Role-specific fields
                        if (_selectedUserType == AppConstants.student)
                          ..._buildStudentFields(),
                        if (_selectedUserType == AppConstants.teacher)
                          ..._buildTeacherFields(),
                        if (_selectedUserType == AppConstants.parent)
                          ..._buildParentFields(),

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: _selectedUserType == AppConstants.student
                                ? 'Email Address'
                                : _selectedUserType == AppConstants.teacher
                                ? 'Email Address'
                                : AppConstants.email,
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: AppConstants.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Confirm password field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: AppConstants.confirmPassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Sign up button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      final additionalData = <String, String>{
                                        'userType': _selectedUserType,
                                      };

                                      if (_selectedUserType == AppConstants.student) {
                                        additionalData['studentId'] =
                                            _studentIdController.text.trim();
                                      } else if (_selectedUserType == AppConstants.teacher) {
                                        additionalData['employeeId'] =
                                            _employeeIdController.text.trim();
                                      } else if (_selectedUserType == AppConstants.parent) {
                                        additionalData['childName'] =
                                            _childNameController.text.trim();
                                      }

                                      context.read<AuthBloc>().add(
                                        SignUpWithEmailEvent(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                          fullName: _nameController.text.trim(),
                                          userType: _selectedUserType,
                                          additionalData: additionalData,
                                        ),
                                      );
                                    }
                                  },
                            child: state is AuthLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    AppConstants.signUp,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Terms and Privacy Policy
                        Text.rich(
                          TextSpan(
                            text: 'By signing up, you agree to EduBridge\'s ',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? const Color(0xFF94A3B8) : null,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms & Privacy Policy',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Or Sign Up with ',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF94A3B8) : const Color.fromARGB(255, 42, 40, 40),
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Social login buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        context.read<AuthBloc>().add(
                                          LoginWithGoogleEvent(),
                                        );
                                      },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.black26),
                                  backgroundColor: isDark ? Colors.grey[850] : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                icon: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        'https://developers.google.com/identity/images/g-logo.png',
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                label: Text(
                                  'Google',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: state is AuthLoading ? null : () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                  side: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.black26),
                                  backgroundColor: isDark ? Colors.grey[850] : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.apple,
                                  size: 20,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                label: Text(
                                  'Apple',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: state is AuthLoading ? null : () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 12,
                                  ),
                                  side: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.black26),
                                  backgroundColor: isDark ? Colors.grey[850] : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.facebook,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                label: Text(
                                  'Facebook',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color.fromARGB(255, 42, 40, 40),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              child: Text(
                                AppConstants.login,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Modal Barrier (blur overlay)
              if (_isDropdownOpen)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDropdownOpen = false;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      color: Colors.black.withValues(alpha: 0.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ),
                ),

              // Custom Dropdown
              if (_isDropdownOpen)
                Positioned(
                  top: 200,
                  right: 24,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isDark ? Colors.grey[850]!.withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child: Column(
                            children: [
                              _buildDropdownItem(AppConstants.student, Icons.school),
                              _buildDropdownItem(AppConstants.teacher, Icons.person_outline),
                              _buildDropdownItem(AppConstants.parent, Icons.family_restroom),
                              _buildDropdownItem(AppConstants.admin, Icons.admin_panel_settings),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  IconData _getUserTypeIcon(String userType) {
    switch (userType) {
      case AppConstants.student:
        return Icons.school;
      case AppConstants.teacher:
        return Icons.person_outline;
      case AppConstants.parent:
        return Icons.family_restroom;
      case AppConstants.admin:
        return Icons.admin_panel_settings;
      default:
        return Icons.person_outline;
    }
  }

  String _getSignupTitle() {
    switch (_selectedUserType) {
      case AppConstants.student:
        return AppConstants.studentSignup;
      case AppConstants.teacher:
        return AppConstants.teacherSignup;
      case AppConstants.parent:
        return AppConstants.parentSignup;
      case AppConstants.admin:
        return AppConstants.adminSignup;
      default:
        return 'Create Account';
    }
  }

  String _getSignupSubtitle() {
    switch (_selectedUserType) {
      case AppConstants.student:
        return 'Start your educational journey with us';
      case AppConstants.teacher:
        return 'Empower students with your expertise';
      case AppConstants.parent:
        return 'Stay connected with your child\'s education';
      case AppConstants.admin:
        return 'Manage and oversee the entire platform';
      default:
        return 'Join us and start your learning adventure';
    }
  }

  List<Widget> _buildStudentFields() {
    return [];
  }

  List<Widget> _buildTeacherFields() {
    return [];
  }

  List<Widget> _buildParentFields() {
    return [
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Make sure to enter the exact name as registered by your student',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _childNameController,
        decoration: InputDecoration(
          labelText: 'Student Name',
          prefixIcon: const Icon(Icons.child_care_outlined),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: Colors.blue),
            onPressed: () => _showStudentSearchDialog(),
            tooltip: 'Search for student',
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your student\'s name';
          }
          if (value.length < 2) {
            return 'Name must be at least 2 characters';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildDropdownItem(String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserType = value;
          _isDropdownOpen = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _selectedUserType == value
              ? Colors.blue.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: _selectedUserType == value ? Colors.blue : (isDark ? Colors.white : Colors.black87),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                color: _selectedUserType == value ? Colors.blue : (isDark ? Colors.white : Colors.black87),
                fontWeight: _selectedUserType == value
                    ? FontWeight.bold
                    : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}