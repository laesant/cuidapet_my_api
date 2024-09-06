import 'dart:async';
import 'dart:convert';
import 'package:cuidapet_my_api/application/exceptions/user_exists_exception.dart';
import 'package:cuidapet_my_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_my_api/application/helpers/jwt_helper.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/entities/user.dart';
import 'package:cuidapet_my_api/modules/user/service/i_user_service.dart';
import 'package:cuidapet_my_api/modules/user/view_models/login_model.dart';
import 'package:cuidapet_my_api/modules/user/view_models/user_save_input_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'auth_controller.g.dart';

@Injectable()
class AuthController {
  final IUserService _userService;
  final ILogger _log;

  const AuthController(
      {required IUserService userService, required ILogger log})
      : _userService = userService,
        _log = log;

  @Route.post('/')
  Future<Response> login(Request request) async {
    try {
      final loginModel = LoginModel(await request.readAsString());
      User user;
      if (!loginModel.socialLogin) {
        user = await _userService.loginWithEmailAndPassword(
            loginModel.login, loginModel.password, loginModel.supplierUser);
      } else {
        // SOCIAL LOGIN (FACEBOOK, GOOGLE, APPLE)
        user = User();
      }

      return Response.ok(jsonEncode({
        'access_token': JwtHelper.generateJWT(user.id!, user.supplierId),
      }));
    } on UserNotfoundException {
      return Response.forbidden(
          jsonEncode({'message': 'Usuário ou senha incorretos'}));
    } catch (e, s) {
      _log.error('Erro ao logar usuário', e, s);
      return Response.internalServerError(
        body: jsonEncode({'message': 'Erro ao logar usuário'}),
      );
    }
  }

  @Route.post('/register')
  Future<Response> saveUser(Request request) async {
    try {
      final userModel = UserSaveInputModel(await request.readAsString());
      await _userService.createUser(userModel);
      return Response.ok(
          jsonEncode({'message': 'Usuario cadastrado com sucesso'}));
    } on UserExistsException {
      return Response.badRequest(
          body: jsonEncode({'message': 'Usuário já cadastrado'}));
    } catch (e) {
      _log.error('Erro ao cadastrar usuário', e);
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao cadastrar usuário'}));
    }
  }

  Router get router => _$AuthControllerRouter(this);
}
