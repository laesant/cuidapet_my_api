import 'package:injectable/injectable.dart';

import './schedule_service.dart';

@LazySingleton(as: ScheduleService)
class ScheduleServiceImpl implements ScheduleService {}
