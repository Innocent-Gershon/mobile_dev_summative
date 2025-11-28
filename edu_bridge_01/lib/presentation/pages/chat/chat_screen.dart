import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../bloc/language/language_bloc.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/models/chat_model.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/chat/chat_event.dart';
import '../../bloc/chat/chat_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import 'new_chat_screen.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(chatRepository: ChatRepository()),
      child: const _ChatScreenContent(),
    );
  }
}

class _ChatScreenContent extends StatefulWidget {
  const _ChatScreenContent();

  @override
  State<_ChatScreenContent> createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<_ChatScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All Chats';

  @override
  void initState() {
    super.initState();
    // Load chats for the current user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        print('Loading chats for user: ${authState.userId}');
        context.read<ChatBloc>().add(LoadChats(authState.userId));
      } else {
        print('User not authenticated, cannot load chats');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildFilterTabs(),
        const SizedBox(height: 10),
        Expanded(child: _buildChatList()),
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
        body: SafeArea(
          child: isLandscape
              ? SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: content,
                  ),
                )
              : content,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? const Color(0xFF334155) : AppColors.border, width: 1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_horiz, color: isDark ? Colors.white : AppColors.textPrimary, size: 24),
              padding: EdgeInsets.zero,
            ),
          ),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? const Color(0xFF334155) : AppColors.border, width: 1),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.camera_alt, color: isDark ? Colors.white : AppColors.textPrimary, size: 24),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: IconButton(
                  onPressed: () => _navigateToNewChat(),
                  icon: const Icon(Icons.add, color: Colors.white, size: 24),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, languageState) {
              return Text(
                AppLocalizations.translate(context, 'messages'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontSize: 32,
                    ),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: AppLocalizations.translate(context, 'search'),
                hintStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9E9E9E)),
                prefixIcon: Icon(Icons.search, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9E9E9E), size: 22),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'name': 'All Chats', 'badge': null},
      {'name': 'Recent Chats', 'badge': null},
      {'name': 'Unread', 'badge': null},
      {'name': 'Groups', 'badge': null},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['name'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = filter['name']!);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  filter['name']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary),
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatList() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        print('ChatBloc state: ${state.runtimeType}');
        
        if (state is ChatLoading) {
          print('Showing loading indicator');
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (state is ChatsLoaded) {
          print('Chats loaded: ${state.chats.length} chats');
          if (state.chats.isEmpty) {
            print('No chats found, showing empty state');
            return _buildEmptyState();
          }
          return _buildChatsListView(state.chats);
        }

        if (state is ChatError) {
          print('Chat error: ${state.message}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load chats',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      context.read<ChatBloc>().add(LoadChats(authState.userId));
                    }
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        print('Showing empty state (default)');
        return _buildEmptyState();
      },
    );
  }

  Widget _buildChatsListView(List<ChatModel> chats) {
    // Filter chats based on search query
    final filteredChats = _searchController.text.isEmpty
        ? chats
        : chats.where((chat) {
            return chat.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                   chat.lastMessage.toLowerCase().contains(_searchController.text.toLowerCase());
          }).toList();

    // Apply filter tabs
    final displayChats = _applyFilter(filteredChats);

    if (displayChats.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: displayChats.length,
      itemBuilder: (context, index) {
        final chat = displayChats[index];
        return _buildChatItem(chat);
      },
    );
  }

  List<ChatModel> _applyFilter(List<ChatModel> chats) {
    switch (_selectedFilter) {
      case 'Recent Chats':
        // Sort by most recent
        final sorted = List<ChatModel>.from(chats);
        sorted.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
        return sorted.take(10).toList();
      case 'Unread':
        // Filter unread
        return chats.where((chat) => chat.unreadCount > 0).toList();
      case 'Groups':
        // Filter groups
        return chats.where((chat) => chat.isGroup).toList();
      case 'All Chats':
      default:
        return chats;
    }
  }

  Widget _buildChatItem(ChatModel chat) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          onTap: () => _navigateToChatDetail(chat),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                _buildChatAvatar(chat),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTime(chat.lastMessageTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: chat.unreadCount > 0
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: chat.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.lastMessage.isEmpty
                                  ? 'No messages yet'
                                  : '${chat.lastMessageSender}: ${chat.lastMessage}',
                              style: TextStyle(
                                fontSize: 14,
                                color: chat.unreadCount > 0
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontWeight: chat.unreadCount > 0
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (chat.unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  chat.unreadCount > 99
                                      ? '99+'
                                      : chat.unreadCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatAvatar(ChatModel chat) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: chat.avatarUrl != null
            ? ClipOval(
                child: Image.network(
                  chat.avatarUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              )
            : Text(
                chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _navigateToChatDetail(ChatModel chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(chat: chat),
      ),
    );
  }

  Widget _buildEmptyState() {
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
              Icons.chat_bubble_outline,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          BlocBuilder<LanguageBloc, LanguageState>(
            builder: (context, languageState) {
              return Column(
                children: [
                  Text(
                    AppLocalizations.translate(context, 'no_conversations'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.translate(context, 'start_conversation'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                            ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }





  void _navigateToNewChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewChatScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}