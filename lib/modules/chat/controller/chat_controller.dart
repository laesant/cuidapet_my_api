import 'dart:async';
import 'dart:convert';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/modules/chat/service/chat_service.dart';
import 'package:cuidapet_my_api/modules/chat/view_models/chat_notify_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'chat_controller.g.dart';

@Injectable()
class ChatController {
  final ChatService _chatService;
  final ILogger _log;

  ChatController({required ChatService chatService, required ILogger log})
      : _log = log,
        _chatService = chatService;

  @Route.post('/schedule/<scheduleId>/start-chat')
  Future<Response> startChatByScheduleId(
      Request request, String scheduleId) async {
    try {
      final chatId = await _chatService.startChat(int.parse(scheduleId));
      return Response.ok(jsonEncode({'chat_id': chatId}));
    } catch (e, s) {
      _log.error('Erro ao iniciar chat.', e, s);
      return Response.internalServerError();
    }
  }

  @Route.post('/notify')
  Future<Response> notifyUser(Request request) async {
    final model = ChatNotifyModel(await request.readAsString());
    return Response.ok(jsonEncode(''));
  }

  Router get router => _$ChatControllerRouter(this);
}
