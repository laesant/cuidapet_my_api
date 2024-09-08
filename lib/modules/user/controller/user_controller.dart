import 'dart:async';
import 'dart:convert';
import 'package:cuidapet_my_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/modules/user/service/i_user_service.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'user_controller.g.dart';

@Injectable()
class UserController {
  final IUserService _userService;
  final ILogger _log;

  const UserController(
      {required IUserService userService, required ILogger log})
      : _userService = userService,
        _log = log;

  @Route.get('/')
  Future<Response> findByToken(Request request) async {
    try {
      final user =
          await _userService.findBydId(int.parse(request.headers['user']!));
      return Response.ok(jsonEncode({
        'email': user.email,
        'register_type': user.registerType,
        'img_avatar': user.imageAvatar,
      }));
    } on UserNotfoundException {
      return Response(204,
          body: jsonEncode({'message': 'Usuário não encontrado'}));
    } catch (e) {
      _log.error('Erro ao buscar usuário', e);
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao buscar usuário'}));
    }
  }

  Router get router => _$UserControllerRouter(this);
}
