import 'package:cuidapet_my_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/entities/user.dart';
import 'package:cuidapet_my_api/modules/user/data/i_user_repository.dart';
import 'package:cuidapet_my_api/modules/user/view_models/user_save_input_model.dart';
import 'package:injectable/injectable.dart';

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
}
