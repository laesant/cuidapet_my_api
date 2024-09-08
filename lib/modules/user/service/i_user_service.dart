import 'package:cuidapet_my_api/entities/user.dart';
import 'package:cuidapet_my_api/modules/user/view_models/refresh_token_model.dart';
import 'package:cuidapet_my_api/modules/user/view_models/user_confirm_input_model.dart';
import 'package:cuidapet_my_api/modules/user/view_models/user_refresh_token_input_model.dart';
import 'package:cuidapet_my_api/modules/user/view_models/user_save_input_model.dart';

abstract interface class IUserService {
  Future<User> createUser(UserSaveInputModel user);
  Future<User> loginWithEmailAndPassword(
      String email, String password, bool supplierUser);
  Future<User> loginByEmailSocialKey(
      String email, String avatar, String socialKey, String socialType);
  Future<String> confirmLogin(UserConfirmInputModel inputModel);
  Future<RefreshTokenModel> refreshToken(UserRefreshTokenInputModel inputModel);
}
