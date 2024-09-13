import 'package:cuidapet_my_api/entities/schedule.dart';
import 'package:cuidapet_my_api/modules/schedules/view_models/schedule_input_model.dart';

abstract interface class ScheduleService {
  Future<void> scheduleServices(ScheduleInputModel model);
  Future<void> changeStatus(String status, int scheduleId);
  Future<List<Schedule>> findAllByUser(int userId);
  Future<List<Schedule>> findAllByUserSupplier(int userId);
}
