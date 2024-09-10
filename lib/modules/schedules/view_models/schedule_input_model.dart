import 'package:cuidapet_my_api/application/helpers/request_mapping.dart';

class ScheduleInputModel extends RequestMapping {
  int userId;
  late DateTime scheduleDate;
  late String name;
  late String petName;
  late int supplierId;
  late List<int> services;
  ScheduleInputModel(super.data, {required this.userId});

  @override
  void map() {
    scheduleDate = DateTime.parse(data['schedule_date']);
    supplierId = data['supplier_id'];
    name = data['name'];
    petName = data['pet_name'];
    services = List.castFrom<dynamic, int>(data['services']);
  }
}
