import 'package:cuidapet_my_api/modules/chat/data/chat_repository.dart';
import 'package:cuidapet_my_api/modules/chat/view_models/chat_notify_model.dart';
import 'package:injectable/injectable.dart';

import './chat_service.dart';

@LazySingleton(as: ChatService)
class ChatServiceImpl implements ChatService {
  final ChatRepository _repository;

  ChatServiceImpl({required ChatRepository repository})
      : _repository = repository;
  @override
  Future<int> startChat(int scheduleId) => _repository.startChat(scheduleId);

  @override
  Future<void> notifyChat(ChatNotifyModel model) async {
    final chat = await _repository.findChatById(model.chat);
    switch (model.notificationUserType) {
      case NotificationUserType.user:
        break;
      case NotificationUserType.supplier:
        break;
      default:
        throw Exception('Tipo de notificação inválido.');
    }
  }
}
