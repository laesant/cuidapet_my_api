import 'package:cuidapet_my_api/application/database/i_database_connection.dart';
import 'package:cuidapet_my_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_my_api/application/exceptions/user_exists_exception.dart';
import 'package:cuidapet_my_api/application/exceptions/user_notfound_exception.dart';
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

  @override
  Future<User> loginWithEmailAndPassword(
      String email, String password, bool supplierUser) async {
    late final MySqlConnection? conn;
    try {
      conn = await _connection.openConnection();
      var query = '''
        select * from usuario where email = ? and senha = ?
        ''';
      if (supplierUser) {
        query += 'and fornecedor_id is not null';
      } else {
        query += 'and fornecedor_id is null';
      }

      final result = await conn
          .query(query, [email, CriptyHelper.generateSha256Hash(password)]);

      if (result.isEmpty) {
        _log.error('Usuário ou senha incorretos');
        throw UserNotfoundException(message: 'Usuário ou senha incorretos');
      } else {
        final userSqlData = result.first;
        return User(
          id: userSqlData['id'],
          email: userSqlData['email'],
          registerType: userSqlData['tipo_cadastro'],
          iosToken: (userSqlData['ios_token'] as Blob?)?.toString(),
          androidToken: (userSqlData['android_token'] as Blob?)?.toString(),
          refreshToken: (userSqlData['refresh_token'] as Blob?)?.toString(),
          imageAvatar: (userSqlData['img_avatar'] as Blob?)?.toString(),
          supplierId: userSqlData['fornecedor_id'],
          //  socialKey: userSqlData['social_id'],
        );
      }
    } on MySqlException catch (e, s) {
      _log.error('Erro ao logar usuário', e, s);
      throw DatabaseException(message: e.message, exception: e);
    } finally {
      await conn?.close();
    }
  }

  @override
  Future<User> loginByEmailSocialKey(
      String email, String socialKey, String socialType) async {
    late final MySqlConnection? conn;
    try {
      conn = await _connection.openConnection();
      final result =
          await conn.query('select * from usuario where email = ?', [email]);
      if (result.isEmpty) {
        throw UserNotfoundException(message: 'Usuário não encontrado');
      } else {
        final dataSql = result.first;
        if (dataSql['social_id'] == null || dataSql['social_id'] != socialKey) {
          await conn.query(
            'update usuario set social_id = ?, tipo_cadastro = ? where id = ?',
            [socialKey, socialType, dataSql['id']],
          );
        }
        return User(
          id: dataSql['id'],
          email: dataSql['email'],
          registerType: dataSql['tipo_cadastro'],
          iosToken: (dataSql['ios_token'] as Blob?)?.toString(),
          androidToken: (dataSql['android_token'] as Blob?)?.toString(),
          refreshToken: (dataSql['refresh_token'] as Blob?)?.toString(),
          imageAvatar: (dataSql['img_avatar'] as Blob?)?.toString(),
          supplierId: dataSql['fornecedor_id'],
          //socialKey: dataSql['social_id'],
        );
      }
    } finally {
      await conn?.close();
    }
  }
}
