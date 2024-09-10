import 'package:injectable/injectable.dart';

import './schedule_repository.dart';

@LazySingleton(as: ScheduleRepository)
class ScheduleRepositoryImpl implements ScheduleRepository {}
