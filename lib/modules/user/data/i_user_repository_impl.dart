import 'package:cuidapet_my_api/application/database/i_database_connection.dart';
import 'package:cuidapet_my_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_my_api/application/exceptions/user_exists_exception.dart';
import 'package:cuidapet_my_api/application/helpers/cripty_helper.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/entities/user.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import './i_user_repository.dart';

@LazySingleton(as: IUserRepository)
class IUserRepositoryImpl implements IUserRepository {
  final IDatabaseConnection _connection;
  final ILogger _log;

  IUserRepositoryImpl(
      {required IDatabaseConnection connection, required ILogger log})
      : _connection = connection,
        _log = log;

  @override
  Future<User> createUser(User user) async {
    late final MySqlConnection? conn;

    try {
      conn = await _connection.openConnection();
      final query = '''
      insert usuario(email, tipo_cadastro, img_avatar, senha, fornecedor_id, social_id)
      values(?, ?, ?, ?, ?, ?)
      ''';

      final result = await conn.query(query, [
        user.email,
        user.registerType,
        user.imageAvatar,
        CriptyHelper.generateSha256Hash(user.password!),
        user.supplierId,
        user.socialKey,
      ]);

      final userId = result.insertId;

      return user.copyWith(id: userId, password: null);
    } on MySqlException catch (e, s) {
      if (e.message.contains('usuario.email_UNIQUE')) {
        _log.error('Usuário já cadastrado na base de dados', e, s);
        throw UserExistsException();
      }
      _log.error('Erro ao criar usuario', e, s);
      throw DatabaseException(message: 'Erro ao criar usuário', exception: e);
    } finally {
      await conn?.close();
    }
  }
}
