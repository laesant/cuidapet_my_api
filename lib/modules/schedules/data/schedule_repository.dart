import 'package:cuidapet_my_api/entities/schedule.dart';

abstract interface class ScheduleRepository {
  Future<void> save(Schedule schedule);
  Future<void> changeStatus(String status, int scheduleId);
}
