import 'package:cuidapet_my_api/entities/schedule.dart';
import 'package:cuidapet_my_api/entities/schedule_service_entity.dart';
import 'package:cuidapet_my_api/entities/supplier.dart';
import 'package:cuidapet_my_api/entities/supplier_service_entity.dart';
import 'package:cuidapet_my_api/modules/schedules/data/schedule_repository.dart';
import 'package:cuidapet_my_api/modules/schedules/view_models/schedule_input_model.dart';
import 'package:injectable/injectable.dart';

import './schedule_service.dart';

@LazySingleton(as: ScheduleService)
class ScheduleServiceImpl implements ScheduleService {
  final ScheduleRepository _repository;
  const ScheduleServiceImpl({required ScheduleRepository repository})
      : _repository = repository;
  @override
  Future<void> scheduleServices(ScheduleInputModel model) => _repository.save(
        Schedule(
          scheduleDate: model.scheduleDate,
          name: model.name,
          petName: model.petName,
          supplier: Supplier(id: model.supplierId),
          status: 'P',
          userId: model.userId,
          services: model.services
              .map((e) =>
                  ScheduleServiceEntity(service: SupplierServiceEntity(id: e)))
              .toList(),
        ),
      );
}
