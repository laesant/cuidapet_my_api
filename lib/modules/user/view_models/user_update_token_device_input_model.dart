import 'package:cuidapet_my_api/application/helpers/request_mapping.dart';
import 'package:cuidapet_my_api/modules/user/view_models/platform.dart';

class UserUpdateTokenDeviceInputModel extends RequestMapping {
  int userId;
  late String token;
  late Platform platform;

  UserUpdateTokenDeviceInputModel(
    super.data, {
    required this.userId,
  });

  @override
  void map() {
    token = data['token'];
    platform = data['platform'].toLowerCase() == 'ios'
        ? Platform.ios
        : Platform.android;
  }
}
