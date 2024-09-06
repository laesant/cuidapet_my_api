import 'package:cuidapet_my_api/application/helpers/request_mapping.dart';

class LoginModel extends RequestMapping {
  late String login;
  late String password;
  late bool socialLogin;
  late bool supplierUser;

  LoginModel(super.data);

  @override
  void map() {
    login = data['login'];
    password = data['password'];
    socialLogin = data['social_login'];
    supplierUser = data['supplier_user'];
  }
}
