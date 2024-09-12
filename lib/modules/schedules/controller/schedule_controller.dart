import 'dart:async';
import 'dart:convert';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/modules/schedules/service/schedule_service.dart';
import 'package:cuidapet_my_api/modules/schedules/view_models/schedule_input_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'schedule_controller.g.dart';

@Injectable()
class ScheduleController {
  final ScheduleService _scheduleService;
  final ILogger _log;
  const ScheduleController(
      {required ScheduleService scheduleService, required ILogger log})
      : _scheduleService = scheduleService,
        _log = log;

  @Route.post('/')
  Future<Response> scheduleServices(Request request) async {
    try {
      final userId = int.parse(request.headers['user']!);
      final model =
          ScheduleInputModel(await request.readAsString(), userId: userId);
      await _scheduleService.scheduleServices(model);
      return Response.ok(jsonEncode({}));
    } catch (e, s) {
      _log.error('Erro ao salvar agendamento', e, s);
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao salvar agendamento'}));
    }
  }

  @Route.put('/<scheduleId|[0-9]+>/status/<status>')
  Future<Response> chnageStatus(
      Request request, String scheduleId, String status) async {
    try {
      await _scheduleService.changeStatus(status, int.parse(scheduleId));
      return Response.ok(jsonEncode({}));
    } catch (e, s) {
      _log.error('Erro ao alterar status do agendamento', e, s);
      return Response.internalServerError(
          body:
              jsonEncode({'message': 'Erro ao alterar status do agendamento'}));
    }
  }

  @Route.get('/')
  Future<Response> findAllSchedulesByUser(Request request) async {
    try {
      final result = await _scheduleService
          .findAllByUser(int.parse(request.headers['user']!));
      final response = result
          .map((e) => {
                'id': e.id,
                'schedule_date': e.scheduleDate.toIso8601String(),
                'status': e.status,
                'name': e.name,
                'pet_name': e.petName,
                'supplier': {
                  'id': e.supplier.id,
                  'name': e.supplier.name,
                  'logo': e.supplier.logo,
                },
                'services': e.services
                    .map((s) => {
                          'id': s.service.id,
                          'name': s.service.name,
                          'price': s.service.price,
                        })
                    .toList()
              })
          .toList();
      return Response.ok(jsonEncode(response));
    } catch (e, s) {
      _log.error('Erro ao buscar agendamentos do usuario', e, s);
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao buscar agendamentos'}));
    }
  }

  Router get router => _$ScheduleControllerRouter(this);
}
