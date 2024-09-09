import 'dart:async';
import 'dart:convert';
import 'package:cuidapet_my_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/modules/user/service/i_user_service.dart';
import 'package:cuidapet_my_api/modules/user/view_models/update_url_avatar_model.dart';
import 'package:cuidapet_my_api/modules/user/view_models/user_update_token_device_input_model.dart';
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

  @Route.put('/avatar')
  Future<Response> updateAvatar(Request request) async {
    try {
      final updateUrlAvatarModel = UpdateUrlAvatarModel(
          await request.readAsString(),
          userId: int.parse(request.headers['user']!));
      final user = await _userService.updateAvatar(updateUrlAvatarModel);
      return Response.ok(jsonEncode({
        'email': user.email,
        'register_type': user.registerType,
        'img_avatar': user.imageAvatar,
      }));
    } catch (e, s) {
      _log.error('Erro ao atualizar avatar', e, s);
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao atualizar avatar'}));
    }
  }

  @Route.put('/device')
  Future<Response> updateDeviceToken(Request request) async {
    try {
      final updateDeviceToken = UserUpdateTokenDeviceInputModel(
          await request.readAsString(),
          userId: int.parse(request.headers['user']!));
      await _userService.updateDeviceToken(updateDeviceToken);
      return Response.ok(jsonEncode({'message': 'Token atualizado'}));
    } catch (e, s) {
      _log.error('Erro ao atualizar token de dispositivo', e, s);
      return Response.internalServerError(
          body: jsonEncode(
              {'message': 'Erro ao atualizar token de dispositivo'}));
    }
  }

  Router get router => _$UserControllerRouter(this);
}
