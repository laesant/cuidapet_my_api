import 'package:cuidapet_my_api/entities/user.dart';

abstract interface class IUserRepository {
  Future<User> createUser(User user);
  Future<User> loginWithEmailAndPassword(
      String email, String password, bool supplierUser);
  Future<User> loginByEmailSocialKey(
      String email, String socialKey, String socialType);
  Future<void> updateUserDeviceTokenAndRefreshToken(User user);
}
