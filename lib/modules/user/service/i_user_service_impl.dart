import 'package:cuidapet_my_api/application/exceptions/service_exception.dart';
import 'package:cuidapet_my_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_my_api/application/helpers/jwt_helper.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/entities/user.dart';
import 'package:cuidapet_my_api/modules/user/data/i_user_repository.dart';
import 'package:cuidapet_my_api/modules/user/view_models/refresh_token_model.dart';
import 'package:cuidapet_my_api/modules/user/view_models/user_confirm_input_model.dart';
import 'package:cuidapet_my_api/modules/user/view_models/user_refresh_token_input_model.dart';
import 'package:cuidapet_my_api/modules/user/view_models/user_save_input_model.dart';
import 'package:injectable/injectable.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import './i_user_service.dart';

@LazySingleton(as: IUserService)
class IUserServiceImpl implements IUserService {
  final IUserRepository _userRepository;
  final ILogger _log;

  IUserServiceImpl(
      {required IUserRepository userRepository, required ILogger log})
      : _userRepository = userRepository,
        _log = log;
  @override
  Future<User> createUser(UserSaveInputModel user) =>
      _userRepository.createUser(User(
        email: user.email,
        password: user.password,
        registerType: 'App',
        supplierId: user.supplierId,
      ));

  @override
  Future<User> loginWithEmailAndPassword(
          String email, String password, bool supplierUser) =>
      _userRepository.loginWithEmailAndPassword(email, password, supplierUser);

  @override
  Future<User> loginByEmailSocialKey(
      String email, String avatar, String socialKey, String socialType) async {
    try {
      return await _userRepository.loginByEmailSocialKey(
          email, socialKey, socialType);
    } on UserNotfoundException catch (e, s) {
      _log.info('Usuário não encontrado, criando um novo usuário', e, s);
      final user = User(
        email: email,
        imageAvatar: avatar,
        registerType: socialType,
        socialKey: socialKey,
        password: DateTime.now().toString(),
      );
      return await _userRepository.createUser(user);
    }
  }

  @override
  Future<String> confirmLogin(UserConfirmInputModel inputModel) async {
    final user = User(
      id: inputModel.userId,
      refreshToken: JwtHelper.refreshToken(inputModel.accessToken),
      iosToken: inputModel.iosDeviceToken,
      androidToken: inputModel.androidDeviceToken,
    );
    await _userRepository.updateUserDeviceTokenAndRefreshToken(user);
    return user.refreshToken!;
  }

  @override
  Future<RefreshTokenModel> refreshToken(
      UserRefreshTokenInputModel inputModel) async {
    _validateRefreshToken(inputModel);
    final newAccessToken =
        JwtHelper.generateJWT(inputModel.user, inputModel.supplier);
    final newRefreshToken =
        JwtHelper.refreshToken(newAccessToken.replaceAll('Bearer ', ''));

    final user = User(
      id: inputModel.user,
      refreshToken: newRefreshToken,
    );
    await _userRepository.updateRefreshToken(user);

    return RefreshTokenModel(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );
  }

  void _validateRefreshToken(UserRefreshTokenInputModel inputModel) {
    try {
      final refreshToken = inputModel.refreshToken.split(' ');

      if (refreshToken.length != 2 || refreshToken[0] != 'Bearer') {
        _log.error('Refresh token inválido');
        throw ServiceException('Refresh token inválido');
      }

      final refreshTokenClaim = JwtHelper.getClaim(refreshToken[1]);
      refreshTokenClaim.validate(issuer: inputModel.accessToken);
    } on ServiceException {
      rethrow;
    } on JwtException catch (e) {
      _log.error('Refresh token inválido', e);
      throw ServiceException('Refresh token inválido');
    } catch (e) {
      throw ServiceException('Erro ao validar refresh token');
    }
  }
}
