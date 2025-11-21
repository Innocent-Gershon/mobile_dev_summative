import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  StreamSubscription? _chatsSubscription;
  StreamSubscription? _messagesSubscription;

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    on<LoadChats>(_onLoadChats);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<CreateChat>(_onCreateChat);
    on<SearchUsers>(_onSearchUsers);
  }

  void _onLoadChats(LoadChats event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      await _chatsSubscription?.cancel();
      _chatsSubscription = chatRepository.getChats(event.userId).listen(
        (chats) => emit(ChatsLoaded(chats)),
        onError: (error) => emit(ChatError(error.toString())),
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    try {
      await _messagesSubscription?.cancel();
      _messagesSubscription = chatRepository.getMessages(event.chatId).listen(
        (messages) => emit(MessagesLoaded(messages)),
        onError: (error) => emit(ChatError(error.toString())),
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      await chatRepository.sendMessage(event.message);
      emit(MessageSent());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onCreateChat(CreateChat event, Emitter<ChatState> emit) async {
    try {
      final chatId = await chatRepository.createChat(
        name: event.name,
        participants: event.participants,
        isGroup: event.isGroup,
      );
      emit(ChatCreated(chatId));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onSearchUsers(SearchUsers event, Emitter<ChatState> emit) async {
    try {
      final users = await chatRepository.searchUsers(event.query, event.currentUserId);
      emit(UsersSearchResult(users));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}