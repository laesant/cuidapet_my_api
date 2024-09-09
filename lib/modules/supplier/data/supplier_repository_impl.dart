import 'package:cuidapet_my_api/application/database/i_database_connection.dart';
import 'package:cuidapet_my_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/dtos/supplier_near_by_me_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:mysql1/mysql1.dart';

import './supplier_repository.dart';

@LazySingleton(as: SupplierRepository)
class SupplierRepositoryImpl implements SupplierRepository {
  final IDatabaseConnection _connection;
  final ILogger _log;

  SupplierRepositoryImpl(
      {required IDatabaseConnection connection, required ILogger log})
      : _connection = connection,
        _log = log;

  @override
  Future<List<SupplierNearByMeDto>> findNearByPosition(
      double lat, double lng, int distance) async {
    late final MySqlConnection conn;

    try {
      conn = await _connection.openConnection();
      final query = '''
        SELECT f.id, f.nome, f.logo, f.categorias_fornecedor_id, 
        (6371 *
          acos(
            cos(radians($lat)) *
            cos(radians(ST_X(f.latlng))) *
            cos(radians($lng) - radians(ST_Y(f.latlng))) +
            sin(radians($lat)) *
            sin(radians(ST_X(f.latlng)))
          )
        ) AS distancia
        FROM fornecedor f
        HAVING distancia <= $distance
      ''';

      final result = await conn.query(query);
      return result
          .map((e) => SupplierNearByMeDto(
                id: e['id'],
                name: e['nome'],
                logo: (e['logo'] as Blob?)?.toString(),
                distance: e['distancia'],
                categoryId: e['categorias_fornecedor_id'],
              ))
          .toList();
    } on MySqlException catch (e, s) {
      _log.error('Erro ao buscar fornecedores por posição', e, s);
      throw DatabaseException(message: e.message, exception: e);
    } finally {
      await conn.close();
    }
  }
}
