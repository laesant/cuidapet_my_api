import 'package:cuidapet_my_api/entities/chat.dart';

abstract interface class ChatRepository {
  Future<int> startChat(int scheduleId);
  Future<Chat?> findChatById(int id);
  Future<List<Chat>> getChatsByUser(int userId);
  Future<List<Chat>> getChatsBySupplier(int supplierId);
  Future<void> endChat(int chatId);
}
