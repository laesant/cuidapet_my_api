import 'package:cuidapet_my_api/application/helpers/request_mapping.dart';

class LoginModel extends RequestMapping {
  late String login;
  late String? password;
  late bool socialLogin;
  late String avatar;
  late String? socialType;
  late String? socialKey;
  late bool supplierUser;

  LoginModel(super.data);

  @override
  void map() {
    login = data['login'];
    password = data['password'];
    socialLogin = data['social_login'];
    avatar = data['avatar'] ?? '';
    socialType = data['social_type'];
    socialKey = data['social_key'];
    supplierUser = data['supplier_user'];
  }
}
