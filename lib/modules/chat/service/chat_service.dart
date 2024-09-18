import 'package:cuidapet_my_api/entities/chat.dart';
import 'package:cuidapet_my_api/modules/chat/view_models/chat_notify_model.dart';

abstract interface class ChatService {
  Future<int> startChat(int scheduleId);
  Future<void> notifyChat(ChatNotifyModel model);
  Future<List<Chat>> getChatsByUser(int userId);
  Future<List<Chat>> getChatsBySupplier(int supplierId);
}
