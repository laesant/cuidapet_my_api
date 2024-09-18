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
    try {
      final model = ChatNotifyModel(await request.readAsString());
      await _chatService.notifyChat(model);
      return Response.ok(jsonEncode({}));
    } catch (e) {
      _log.error('Erro ao notificar chat.', e);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Erro ao enviar notificação.'}),
      );
    }
  }

  @Route.get('/user')
  Future<Response> findChatsByUser(Request request) async {
    try {
      final user = int.parse(request.headers['user']!);
      final chats = await _chatService.getChatsByUser(user);
      return Response.ok(jsonEncode(chats
          .map((c) => {
                'id': c.id,
                'user': c.user,
                'nome': c.name,
                'pet_name': c.petName,
                'status': c.status,
                'supplier': {
                  'id': c.supplier.id,
                  'name': c.supplier.name,
                  'logo': c.supplier.logo,
                }
              })
          .toList()));
    } catch (e, s) {
      _log.error('Erro ao buscar chats.', e, s);
      return Response.internalServerError();
    }
  }

  @Route.get('/supplier')
  Future<Response> findChatsBySupplier(Request request) async {
    final supplier = request.headers['supplier'];
    if (supplier == null) {
      return Response.badRequest(
          body: jsonEncode({'error': 'Usuário logado não é um fornecedor'}));
    }
    final supplierId = int.parse(supplier);
    final chats = await _chatService.getChatsBySupplier(supplierId);
    return Response.ok(jsonEncode(chats
        .map((c) => {
              'id': c.id,
              'user': c.user,
              'nome': c.name,
              'pet_name': c.petName,
              'status': c.status,
              'supplier': {
                'id': c.supplier.id,
                'name': c.supplier.name,
                'logo': c.supplier.logo,
              }
            })
        .toList()));
  }

  Router get router => _$ChatControllerRouter(this);
}
