import 'package:cuidapet_my_api/application/helpers/request_mapping.dart';

enum NotificationUserType {
  user,
  supplier;
}

class ChatNotifyModel extends RequestMapping {
  late int chat;
  late String message;
  late NotificationUserType notificationUserType;
  ChatNotifyModel(super.data);

  @override
  void map() {
    chat = data['chat'];
    message = data['message'];
    String to = data['to'];
    notificationUserType = to.toLowerCase() == 'u'
        ? NotificationUserType.user
        : NotificationUserType.supplier;
  }
}
