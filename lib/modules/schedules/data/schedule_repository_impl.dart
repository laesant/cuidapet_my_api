import 'package:cuidapet_my_api/application/database/i_database_connection.dart';
import 'package:cuidapet_my_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/entities/schedule.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import './schedule_repository.dart';

@LazySingleton(as: ScheduleRepository)
class ScheduleRepositoryImpl implements ScheduleRepository {
  final IDatabaseConnection _connection;
  final ILogger _log;
  ScheduleRepositoryImpl(
      {required IDatabaseConnection connection, required ILogger log})
      : _connection = connection,
        _log = log;
  @override
  Future<void> save(Schedule schedule) async {
    late final MySqlConnection conn;
    try {
      conn = await _connection.openConnection();
      await conn.transaction(
        (_) async {
          final result = await conn.query('''
            insert into 
            agendamento (data_agendamento, usuario_id, fornecedor_id, status, nome, nome_pet)
            values(?, ?, ?, ?, ?, ?)
          ''', [
            schedule.scheduleDate.toIso8601String(),
            schedule.userId,
            schedule.supplier.id,
            schedule.status,
            schedule.name,
            schedule.petName,
          ]);
          final scheduleId = result.insertId!;
          await conn.queryMulti(
            '''
            insert into agendamento_servicos values(?, ?)
          ''',
            schedule.services.map((e) => [scheduleId, e.service.id]),
          );
        },
      );
    } on MySqlException catch (e, s) {
      _log.error('Erro ao agendar serviço', e, s);
      throw DatabaseException(message: e.message, exception: e);
    } finally {
      await conn.close();
    }
  }

  @override
  Future<void> changeStatus(String status, int scheduleId) async {
    late final MySqlConnection conn;
    try {
      conn = await _connection.openConnection();
      await conn.query('''
            update agendamento set status = ? where id = ?
          ''', [status, scheduleId]);
    } on MySqlException catch (e, s) {
      _log.error('Erro ao alterar status do agendamento', e, s);
      throw DatabaseException(message: e.message, exception: e);
    } finally {
      await conn.close();
    }
  }
}
