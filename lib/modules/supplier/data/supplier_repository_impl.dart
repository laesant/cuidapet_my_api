import 'package:cuidapet_my_api/application/database/i_database_connection.dart';
import 'package:cuidapet_my_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/dtos/supplier_near_by_me_dto.dart';
import 'package:cuidapet_my_api/entities/category.dart';
import 'package:cuidapet_my_api/entities/supplier.dart';
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

  @override
  Future<Supplier?> findById(int id) async {
    late final MySqlConnection conn;

    try {
      conn = await _connection.openConnection();
      final query = '''
        SELECT f.id, f.nome, f.logo, f.endereco, f.telefone, ST_X(f.latlng) as lat, ST_Y(f.latlng) as lng,
        f.categorias_fornecedor_id, c.nome_categoria, c.tipo_categoria
        FROM fornecedor f
        inner join categorias_fornecedor as c on (f.categorias_fornecedor_id = c.id)
        WHERE f.id = $id
      ''';

      final result = await conn.query(query);
      if (result.isEmpty) return null;

      return Supplier(
        id: result.first['id'],
        name: result.first['nome'],
        logo: (result.first['logo'] as Blob?)?.toString(),
        address: result.first['endereco'],
        phone: result.first['telefone'],
        lat: result.first['lat'],
        lng: result.first['lng'],
        category: Category(
          ind: result.first['categorias_fornecedor_id'],
          name: result.first['nome_categoria'],
          type: result.first['tipo_categoria'],
        ),
      );
    } on MySqlException catch (e, s) {
      _log.error('Erro ao buscar fornecedor por id', e, s);
      throw DatabaseException(message: e.message, exception: e);
    } finally {
      await conn.close();
    }
  }
}