import 'package:cuidapet_my_api/entities/user.dart';
import 'package:cuidapet_my_api/modules/user/data/i_user_repository.dart';
import 'package:cuidapet_my_api/modules/user/view_models/user_save_input_model.dart';
import 'package:injectable/injectable.dart';

import './i_user_service.dart';

@LazySingleton(as: IUserService)
class IUserServiceImpl implements IUserService {
  final IUserRepository _userRepository;

  IUserServiceImpl({required IUserRepository userRepository})
      : _userRepository = userRepository;
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
}
