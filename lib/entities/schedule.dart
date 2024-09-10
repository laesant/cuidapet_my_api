import 'package:cuidapet_my_api/entities/schedule_service_entity.dart';
import 'package:cuidapet_my_api/entities/supplier.dart';

class Schedule {
  final int? id;
  final DateTime scheduleDate;
  final String status;
  final String name;
  final String petName;
  final int userId;
  final Supplier supplier;
  final List<ScheduleServiceEntity> services;

  Schedule({
    this.id,
    required this.scheduleDate,
    required this.status,
    required this.name,
    required this.petName,
    required this.userId,
    required this.supplier,
    required this.services,
  });
}
