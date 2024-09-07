import 'package:cuidapet_my_api/application/helpers/request_mapping.dart';

class UserConfirmInputModel extends RequestMapping {
  int userId;
  String accessToken;
  String? iosDeviceToken;
  String? androidDeviceToken;
  UserConfirmInputModel({
    required String data,
    required this.userId,
    required this.accessToken,
  }) : super(data);

  @override
  void map() {
    iosDeviceToken = data['ios_token'];
    androidDeviceToken = data['android_token'];
  }
}
