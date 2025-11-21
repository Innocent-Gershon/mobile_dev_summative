import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ChatModel>> getChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> sendMessage(MessageModel message) async {
    final batch = _firestore.batch();
    
    // Add message to chat
    final messageRef = _firestore
        .collection('chats')
        .doc(message.chatId)
        .collection('messages')
        .doc();
    
    batch.set(messageRef, message.toMap()..['id'] = messageRef.id);
    
    // Update chat's last message
    final chatRef = _firestore.collection('chats').doc(message.chatId);
    batch.update(chatRef, {
      'lastMessage': message.content,
      'lastMessageTime': message.timestamp,
      'lastMessageSender': message.senderName,
    });
    
    await batch.commit();
  }

  Future<String> createChat({
    required String name,
    required List<String> participants,
    bool isGroup = false,
  }) async {
    final chatRef = _firestore.collection('chats').doc();
    
    final chat = ChatModel(
      id: chatRef.id,
      name: name,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      lastMessageSender: '',
      participants: participants,
      isGroup: isGroup,
    );
    
    await chatRef.set(chat.toMap());
    return chatRef.id;
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query, String currentUserId) async {
    final snapshot = await _firestore
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .limit(10)
        .get();
    
    return snapshot.docs
        .where((doc) => doc.id != currentUserId)
        .map((doc) => {...doc.data(), 'uid': doc.id})
        .toList();
  }
}