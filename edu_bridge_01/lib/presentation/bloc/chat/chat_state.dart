import '../../../data/models/chat_model.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatsLoaded extends ChatState {
  final List<ChatModel> chats;
  ChatsLoaded(this.chats);
}

class MessagesLoaded extends ChatState {
  final List<MessageModel> messages;
  MessagesLoaded(this.messages);
}

class MessageSent extends ChatState {}

class ChatCreated extends ChatState {
  final String chatId;
  ChatCreated(this.chatId);
}

class UsersSearchResult extends ChatState {
  final List<Map<String, dynamic>> users;
  UsersSearchResult(this.users);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}