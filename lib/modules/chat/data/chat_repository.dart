import 'package:cuidapet_my_api/entities/chat.dart';

abstract interface class ChatRepository {
  Future<int> startChat(int scheduleId);
  Future<Chat?> findChatById(int id);
}
