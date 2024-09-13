import 'package:cuidapet_my_api/application/database/i_database_connection.dart';
import 'package:cuidapet_my_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/entities/schedule.dart';
import 'package:cuidapet_my_api/entities/schedule_service_entity.dart';
import 'package:cuidapet_my_api/entities/supplier.dart';
import 'package:cuidapet_my_api/entities/supplier_service_entity.dart';
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

  @override
  Future<List<Schedule>> findAllByUser(int userId) async {
    late final MySqlConnection conn;
    try {
      conn = await _connection.openConnection();
      final result = await conn.query(
        '''
          select 
          a.id, a.data_agendamento, a.status, a.nome, a.nome_pet,
          f.id as fornec_id, f.nome as fornec_nome, f.logo
          from agendamento as a
          inner join fornecedor as f on a.fornecedor_id = f.id
          where a.usuario_id = ?
          order by a.data_agendamento desc
        ''',
        [userId],
      );
      final scheduleResult = result
          .map((e) async => Schedule(
              id: e['id'],
              scheduleDate: e['data_agendamento'],
              status: e['status'],
              name: e['nome'],
              petName: e['nome_pet'],
              userId: userId,
              supplier: Supplier(
                id: e['fornec_id'],
                name: e['fornec_nome'],
                logo: (e['logo'] as Blob?).toString(),
              ),
              services: await findAllServicesBySchedule(e['id'])))
          .toList();
      return Future.wait(scheduleResult);
    } on MySqlException catch (e, s) {
      _log.error('Erro ao buscar agendamentos do usuario', e, s);
      throw DatabaseException(message: e.message, exception: e);
    } finally {
      await conn.close();
    }
  }

  @override
  Future<List<Schedule>> findAllByUserSupplier(int userId) async {
    late final MySqlConnection conn;
    try {
      conn = await _connection.openConnection();
      final result = await conn.query(
        '''
          select 
          a.id, a.data_agendamento, a.status, a.nome, a.nome_pet,
          f.id as fornec_id, f.nome as fornec_nome, f.logo
          from agendamento as a
          inner join fornecedor as f on a.fornecedor_id = f.id
          inner join usuario u on u.fornecedor_id = f.id 
          where u.id = ?
          order by a.data_agendamento desc
        ''',
        [userId],
      );
      final scheduleResult = result
          .map((e) async => Schedule(
              id: e['id'],
              scheduleDate: e['data_agendamento'],
              status: e['status'],
              name: e['nome'],
              petName: e['nome_pet'],
              userId: userId,
              supplier: Supplier(
                id: e['fornec_id'],
                name: e['fornec_nome'],
                logo: (e['logo'] as Blob?).toString(),
              ),
              services: await findAllServicesBySchedule(e['id'])))
          .toList();
      return Future.wait(scheduleResult);
    } on MySqlException catch (e, s) {
      _log.error('Erro ao buscar agendamentos do usuario', e, s);
      throw DatabaseException(message: e.message, exception: e);
    } finally {
      await conn.close();
    }
  }

  Future<List<ScheduleServiceEntity>> findAllServicesBySchedule(
      int scheduleId) async {
    late final MySqlConnection conn;
    try {
      conn = await _connection.openConnection();
      final result = await conn.query(
        '''
          select 
          fs.id, fs.nome_servico, fs.valor_servico, fs.fornecedor_id
          from agendamento_servicos as ags
          inner join fornecedor_servicos as fs on fs.id = ags.fornecedor_servicos_id
          where ags.agendamento_id = ?
        ''',
        [scheduleId],
      );
      return result
          .map((e) => ScheduleServiceEntity(
                service: SupplierServiceEntity(
                  id: e['id'],
                  name: e['nome_servico'],
                  price: e['valor_servico'],
                ),
              ))
          .toList();
    } on MySqlException catch (e, s) {
      _log.error('Erro ao buscar os serviços de um agedamento', e, s);
      throw DatabaseException(message: e.message, exception: e);
    } finally {
      await conn.close();
    }
  }
}
