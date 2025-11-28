import '../../../data/models/chat_model.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatsLoaded extends ChatState {
  final List<ChatModel> chats;
  ChatsLoaded(this.chats);
  
  @override
  List<Object?> get props => [chats];
}

class MessagesLoaded extends ChatState {
  final List<MessageModel> messages;
  MessagesLoaded(this.messages);
  
  @override
  List<Object?> get props => [messages];
}

class MessageSent extends ChatState {}

class ChatCreated extends ChatState {
  final String chatId;
  ChatCreated(this.chatId);
  
  @override
  List<Object?> get props => [chatId];
}

class UsersSearchResult extends ChatState {
  final List<Map<String, dynamic>> users;
  UsersSearchResult(this.users);
  
  @override
  List<Object?> get props => [users];
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
  
  @override
  List<Object?> get props => [message];
}