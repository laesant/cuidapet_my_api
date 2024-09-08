import 'package:cuidapet_my_api/application/helpers/request_mapping.dart';

class UserRefreshTokenInputModel extends RequestMapping {
  int user;
  int? supplier;
  String accessToken;
  late String refreshToken;

  UserRefreshTokenInputModel(
    super.data, {
    required this.user,
    required this.accessToken,
    this.supplier,
  });

  @override
  void map() => refreshToken = data['refresh_token'];
}
