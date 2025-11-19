class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final userType = stringToUserType(state.userType);
          return _HomeScreenContent(
            userType: userType,
            userName: state.name,
            userEmail: state.email,
          );
        }

        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3366FF)),
            ),
          ),
        );
      },
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  final UserType userType;
  final String userName;
  final String userEmail;

  const _HomeScreenContent({
    super.key,
    required this.userType,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  int _selectedIndex = 0;
  int _taskTabIndex = 0; // 0 for Active, 1 for Completed
  
  List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Design task management dashboard',
      description: 'Create wireframes and mockups for the main dashboard.',
      priority: 'High',
      priorityColor: const Color(0xFFFFCC00),
      dueDate: '10 October',
      tags: ['UI', 'Design'],
    ),
    Task(
      id: '2',
      title: 'Implement user authentication',
      description: 'Set up login and registration functionality.',
      priority: 'Medium',
      priorityColor: const Color(0xFF3366FF),
      dueDate: '20 October',
      tags: ['Backend', 'Auth'],
    ),
    Task(
      id: '3',
      title: 'Write unit tests',
      description: 'Create comprehensive test coverage for core features.',
      priority: 'Low',
      priorityColor: const Color(0xFF34C759),
      dueDate: '25 October',
      tags: ['Testing'],
    ),
  ];

  String _getDisplayName() {
    if (widget.userName.isNotEmpty && widget.userName != 'User') {
      return widget.userName;
    }
    
    if (widget.userEmail.isNotEmpty) {
      final emailPart = widget.userEmail.split('@')[0];
      final cleanName = emailPart.replaceAll(RegExp(r'[._]'), ' ');
      return cleanName.split(' ').map((word) => 
        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : ''
      ).join(' ');
    }
    
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: false,
                toolbarHeight: 80,
                backgroundColor: const Color(0xFFF8F9FA),
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: _buildProfileHeader(),
              ),
              SliverToBoxAdapter(child: _buildCategoriesSection()),
              SliverToBoxAdapter(child: _buildMyTaskSection()),
              SliverToBoxAdapter(child: _buildRecentUpdatesSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      color: const Color(0xFFF8F9FA),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
            ),
            child: ClipOval(
              child: Container(
                color: const Color(0xFFFFE4E1),
                child: Center(
                  child: Text(
                    _getDisplayName()[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1A1A1A),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getDisplayName(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3366FF),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          
          // Search Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF0FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Color(0xFF3366FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Notification Icon with Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF0FF),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_rounded,
                    color: Color(0xFF3366FF),
                    size: 24,
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFEBF0FF), width: 1.5),
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

  