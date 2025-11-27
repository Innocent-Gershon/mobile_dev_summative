import '../../../data/models/chat_model.dart';

abstract class ChatEvent {}

class LoadChats extends ChatEvent {
  final String userId;
  LoadChats(this.userId);
}

class LoadMessages extends ChatEvent {
  final String chatId;
  LoadMessages(this.chatId);
}

class SendMessage extends ChatEvent {
  final MessageModel message;
  SendMessage(this.message);
}

class CreateChat extends ChatEvent {
  final String name;
  final List<String> participants;
  final bool isGroup;
  
  CreateChat({
    required this.name,
    required this.participants,
    this.isGroup = false,
  });
}

class SearchUsers extends ChatEvent {
  final String query;
  final String currentUserId;
  
  SearchUsers({
    required this.query,
    required this.currentUserId,
  });
}