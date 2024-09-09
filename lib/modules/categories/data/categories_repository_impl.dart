import 'package:cuidapet_my_api/application/database/i_database_connection.dart';
import 'package:cuidapet_my_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/entities/category.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import './categories_repository.dart';

@LazySingleton(as: CategoriesRepository)
class CategoriesRepositoryImpl implements CategoriesRepository {
  IDatabaseConnection _connection;
  ILogger _log;
  CategoriesRepositoryImpl(
      {required IDatabaseConnection connection, required ILogger log})
      : _connection = connection,
        _log = log;
  @override
  Future<List<Category>> findAll() async {
    late final MySqlConnection conn;

    try {
      conn = await _connection.openConnection();
      final result = await conn.query('SELECT * FROM categorias_fornecedor');
      return result
          .map((e) => Category(
                ind: e['id'],
                name: e['nome_categoria'],
                type: e['tipo_categoria'],
              ))
          .toList();
    } on MySqlException catch (e, s) {
      _log.error('Erro ao buscar categorias', e, s);
      throw DatabaseException(message: e.message, exception: e);
    } finally {
      await conn.close();
    }
  }
}
