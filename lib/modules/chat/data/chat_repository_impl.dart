import 'package:cuidapet_my_api/application/database/i_database_connection.dart';
import 'package:cuidapet_my_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/entities/chat.dart';
import 'package:cuidapet_my_api/entities/device_token.dart';
import 'package:cuidapet_my_api/entities/supplier.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import './chat_repository.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final IDatabaseConnection _connection;
  final ILogger _log;

  ChatRepositoryImpl(
      {required IDatabaseConnection connection, required ILogger log})
      : _connection = connection,
        _log = log;

  @override
  Future<int> startChat(int scheduleId) async {
    late final MySqlConnection? conn;

    try {
      conn = await _connection.openConnection();
      final result = await conn.query(
        'INSERT INTO chats(agendamento_id, status, data_criacao) VALUES (?, ?, ?)',
        [scheduleId, 'A', DateTime.now().toIso8601String()],
      );

      return result.insertId!;
    } on MySqlException catch (e, s) {
      _log.error('Erro ao iniciar chat.', e, s);
      throw DatabaseException(message: e.message);
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<Chat?> findChatById(int id) async {
    late final MySqlConnection? conn;
    try {
      conn = await _connection.openConnection();
      final result = await conn.query(
        '''
          select 
            c.id,
            c.data_criacao,
            c.status,
            a.nome as agendamento_nome,
            a.nome_pet as agendamento_nome_pet,
            a.fornecedor_id,
            a.usuario_id,
            f.nome as fornec_nome,
            f.logo,
            u.android_token as user_android_token,
            u.ios_token as user_ios_token,
            uf.android_token as fornec_android_token,
            uf.ios_token as fornec_ios_token
          from chats as c
          inner join agendamento a on a.id = c.agendamento_id
          inner join fornecedor f on f.id = a.fornecedor_id
          inner join usuario u on u.id = a.usario_id
          inner join usuario uf on uf.fornecedor_id = f.id
          where c.id = ?
        ''',
        [id],
      );

      if (result.isEmpty) return null;
      final row = result.first;
      return Chat(
        id: row['id'],
        status: row['status'],
        name: row['agendamento_nome'],
        petName: row['agendamento_nome_pet'],
        user: row['usuario_id'],
        supplier: Supplier(
          id: row['fornecedor_id'],
          name: row['fornec_nome'],
          logo: row['logo'],
        ),
        userDeviceToken: DeviceToken(
          android: (row['user_android_token'] as Blob?)?.toString(),
          ios: (row['user_ios_token'] as Blob?)?.toString(),
        ),
        supplierDeviceToken: DeviceToken(
          android: (row['fornec_android_token'] as Blob?)?.toString(),
          ios: (row['fornec_ios_token'] as Blob?)?.toString(),
        ),
      );
    } on MySqlException catch (e, s) {
      _log.error('Erro ao buscar chat.', e, s);
      throw DatabaseException(message: e.message);
    } finally {
      await conn?.close();
    }
  }
}
