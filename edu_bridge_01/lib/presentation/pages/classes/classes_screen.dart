import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations.dart';
import '../../bloc/language/language_bloc.dart';
import '../../../data/models/class_model.dart';
import '../../bloc/classes/classes_bloc.dart';
import '../../bloc/classes/classes_event.dart';
import '../../bloc/classes/classes_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../assignments/create_assignment_screen.dart';
import '../assignments/assignment_details_sheet.dart';

class ClassesScreen extends StatelessWidget {
  final String? parentChildName;
  
  const ClassesScreen({super.key, this.parentChildName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClassesBloc()..add(LoadClasses()),
      child: ClassesView(parentChildName: parentChildName),
    );
  }
}

class ClassesView extends StatefulWidget {
  final String? parentChildName;
  
  const ClassesView({super.key, this.parentChildName});

  @override
  State<ClassesView> createState() => _ClassesViewState();
}

class _ClassesViewState extends State<ClassesView> {
  String _searchQuery = '';
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F5F5),
        elevation: 0,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, languageState) {
              return Text(
                widget.parentChildName != null ? '${widget.parentChildName}\'s Assignments' : AppLocalizations.translate(context, 'classes'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -0.5,
                ),
              );
            },
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search, color: isDark ? Colors.white : Colors.black, size: 24),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchQuery = '';
                    _searchController.clear();
                  }
                });
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return IconButton(
                  icon: Icon(Icons.add, color: isDark ? Colors.white : Colors.black, size: 24),
                  onPressed: () async {
                    if (state is AuthAuthenticated && state.userType == 'Teacher') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateAssignmentScreen(),
                        ),
                      );
                      if (result == true && mounted) {
                        context.read<ClassesBloc>().add(RefreshClasses());
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Only teachers can create assignments'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isSearching)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: AppLocalizations.translate(context, 'search_classes'),
                  hintStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF8E8E93)),
                  prefixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF8E8E93)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: BlocBuilder<LanguageBloc, LanguageState>(
                builder: (context, languageState) {
                  return Text(
                    AppLocalizations.translate(context, 'track_projects'),
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF8E8E93),
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: BlocBuilder<ClassesBloc, ClassesState>(
              builder: (context, state) {
                if (state is ClassesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ClassesLoaded) {
                  final filteredClasses = _searchQuery.isEmpty
                      ? state.classes
                      : state.classes.where((cls) => 
                          cls.name.toLowerCase().contains(_searchQuery.toLowerCase())
                        ).toList();
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ClassesBloc>().add(RefreshClasses());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredClasses.length,
                      itemBuilder: (context, index) {
                        return ClassCard(classModel: filteredClasses[index]);
                      },
                    ),
                  );
                } else if (state is ClassesError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ClassCard extends StatelessWidget {
  final ClassModel classModel;

  const ClassCard({super.key, required this.classModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.15), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    classModel.icon,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classModel.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      classModel.teacher,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: classModel.progress,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(classModel.progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Next: ${classModel.nextAssignment}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (classModel.assignedStudents.isNotEmpty)
            const SizedBox(height: 8),
          if (classModel.assignedStudents.isNotEmpty)
            Text(
              'Assigned to: ${classModel.assignedStudents.take(3).join(", ")}${classModel.assignedStudents.length > 3 ? " +${classModel.assignedStudents.length - 3} more" : ""}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                final result = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AssignmentDetailsSheet(assignment: classModel),
                );
                
                if (result == true && context.mounted) {
                  context.read<ClassesBloc>().add(RefreshClasses());
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 17,
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCardColor() {
    switch (classModel.color) {
      case 'blue':
        return const Color(0xFF3B82F6); // Blue
      case 'green':
        return const Color(0xFF10B981); // Green
      case 'purple':
        return const Color(0xFF8B5CF6); // Purple
      case 'orange':
        return const Color(0xFFF59E0B); // Orange
      case 'teal':
        return const Color(0xFF14B8A6); // Teal
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}
