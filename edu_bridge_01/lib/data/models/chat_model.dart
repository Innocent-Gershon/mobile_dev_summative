import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSender;
  final List<String> participants;
  final String? avatarUrl;
  final int unreadCount;
  final bool isGroup;

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSender,
    required this.participants,
    this.avatarUrl,
    this.unreadCount = 0,
    this.isGroup = false,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageSender: map['lastMessageSender'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      avatarUrl: map['avatarUrl'],
      unreadCount: map['unreadCount'] ?? 0,
      isGroup: map['isGroup'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageSender': lastMessageSender,
      'participants': participants,
      'avatarUrl': avatarUrl,
      'unreadCount': unreadCount,
      'isGroup': isGroup,
    };
  }
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.isRead = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${map['type']}',
        orElse: () => MessageType.text,
      ),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.toString().split('.').last,
      'isRead': isRead,
    };
  }
}

enum MessageType {
  text,
  image,
  file,
  system,
}