import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/chat/chat_event.dart';
import '../../bloc/chat/chat_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import 'chat_detail_screen.dart';
import '../../../data/models/chat_model.dart';

class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(chatRepository: ChatRepository()),
      child: const _NewChatContent(),
    );
  }
}

class _NewChatContent extends StatefulWidget {
  const _NewChatContent();

  @override
  State<_NewChatContent> createState() => _NewChatContentState();
}

class _NewChatContentState extends State<_NewChatContent> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
      ),
      title: const Text(
        'New Chat',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for teachers, students, or parents...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildContent() {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is UsersSearchResult) {
          setState(() {
            _searchResults = state.users;
            _isSearching = false;
          });
        } else if (state is ChatCreated) {
          // Navigate to the created chat
          _navigateToChat(state.chatId);
        } else if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (_isSearching) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
            return _buildNoResults();
          }

          if (_searchResults.isNotEmpty) {
            return _buildSearchResults();
          }

          return _buildInitialState();
        },
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_search,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Find People to Chat With',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for teachers, students, or parents\nto start a conversation',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 40,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try searching with a different name',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserItem(user);
      },
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          onTap: () => _createChat(user),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                _buildUserAvatar(user),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getUserTypeColor(user['userType']).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              user['userType'] ?? 'User',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getUserTypeColor(user['userType']),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user['email'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(Map<String, dynamic> user) {
    final name = user['name'] ?? 'U';
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getUserTypeColor(user['userType']).withValues(alpha: 0.1),
        border: Border.all(
          color: _getUserTypeColor(user['userType']).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _getUserTypeColor(user['userType']),
          ),
        ),
      ),
    );
  }

  Color _getUserTypeColor(String? userType) {
    switch (userType?.toLowerCase()) {
      case 'teacher':
        return AppColors.primary;
      case 'student':
        return AppColors.accent;
      case 'parent':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ChatBloc>().add(SearchUsers(
        query: query.trim(),
        currentUserId: authState.userId,
      ));
    }
  }

  void _createChat(Map<String, dynamic> user) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final chatName = user['name'] ?? 'Chat';
      final participants = <String>[
        authState.userId.toString(),
        (user['uid'] ?? '').toString(),
      ];
      
      context.read<ChatBloc>().add(CreateChat(
        name: chatName,
        participants: participants,
        isGroup: false,
      ));
    }
  }

  void _navigateToChat(String chatId) {
    // Create a temporary chat model for navigation
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final selectedUser = _searchResults.firstWhere(
        (user) => (user['uid'] ?? '').toString() != authState.userId.toString(),
        orElse: () => <String, dynamic>{},
      );

      final chat = ChatModel(
        id: chatId,
        name: selectedUser['name'] ?? 'Chat',
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        lastMessageSender: '',
        participants: <String>[
          authState.userId.toString(),
          (selectedUser['uid'] ?? '').toString(),
        ],
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(chat: chat),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}