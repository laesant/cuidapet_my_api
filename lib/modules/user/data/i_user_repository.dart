import 'package:cuidapet_my_api/entities/user.dart';

abstract interface class IUserRepository {
  Future<User> createUser(User user);
}
