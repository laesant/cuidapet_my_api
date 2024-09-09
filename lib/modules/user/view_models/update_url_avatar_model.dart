import 'package:cuidapet_my_api/application/helpers/request_mapping.dart';

class UpdateUrlAvatarModel extends RequestMapping {
  int userId;
  late String urlAvatar;
  UpdateUrlAvatarModel(super.data, {required this.userId});

  @override
  void map() => urlAvatar = data['url_avatar'];
}
