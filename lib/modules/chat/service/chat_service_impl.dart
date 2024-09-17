import 'package:cuidapet_my_api/application/facades/push_notification_facade.dart';
import 'package:cuidapet_my_api/entities/chat.dart';
import 'package:cuidapet_my_api/modules/chat/data/chat_repository.dart';
import 'package:cuidapet_my_api/modules/chat/view_models/chat_notify_model.dart';
import 'package:injectable/injectable.dart';

import './chat_service.dart';

@LazySingleton(as: ChatService)
class ChatServiceImpl implements ChatService {
  final ChatRepository _repository;
  final PushNotificationFacade _pushNotificationFacade;

  ChatServiceImpl(
      {required ChatRepository repository,
      required PushNotificationFacade pushNotificationFacade})
      : _repository = repository,
        _pushNotificationFacade = pushNotificationFacade;
  @override
  Future<int> startChat(int scheduleId) => _repository.startChat(scheduleId);

  @override
  Future<void> notifyChat(ChatNotifyModel model) async {
    final chat = await _repository.findChatById(model.chat);
    if (chat == null) return;
    switch (model.notificationUserType) {
      case NotificationUserType.user:
        _notifyUser(chat.userDeviceToken?.tokens, model, chat);
        break;
      case NotificationUserType.supplier:
        _notifyUser(chat.supplierDeviceToken?.tokens, model, chat);
        break;
      default:
        throw Exception('Tipo de notificação inválido.');
    }
  }

  void _notifyUser(List<String?>? tokens, ChatNotifyModel model, Chat chat) {
    final Map<String, dynamic> payload = {
      'type': 'CHAT_MESSAGE',
      'chat': {
        'id': chat.id,
        'nome': chat.name,
        'fornecedor': {
          'nome': chat.supplier.name,
          'logo': chat.supplier.logo,
        }
      },
    };

    _pushNotificationFacade.sendMessage(
        devices: tokens ?? [],
        title: 'Nova mensagem',
        body: model.message,
        payload: payload);
  }
}
