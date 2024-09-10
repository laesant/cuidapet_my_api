import 'package:cuidapet_my_api/application/database/i_database_connection.dart';
import 'package:cuidapet_my_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/dtos/supplier_near_by_me_dto.dart';
import 'package:cuidapet_my_api/entities/category.dart';
import 'package:cuidapet_my_api/entities/supplier.dart';
import 'package:cuidapet_my_api/entities/supplier_service_entity.dart';
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
        ORDER BY distancia ASC
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
          id: result.first['categorias_fornecedor_id'],
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

  @override
  Future<List<SupplierServiceEntity>> findServicesBySupplierId(
      int supplierId) async {
    late final MySqlConnection conn;

    try {
      conn = await _connection.openConnection();
      final result = await conn.query('''
        SELECT id, fornecedor_id, nome_servico, valor_servico
        FROM fornecedor_servicos
        WHERE fornecedor_id = ?
      ''', [supplierId]);
      if (result.isEmpty) return [];

      return result
          .map((e) => SupplierServiceEntity(
                id: e['id'],
                supplierId: e['fornecedor_id'],
                name: e['nome_servico'],
                price: e['valor_servico'],
              ))
          .toList();
    } on MySqlException catch (e, s) {
      _log.error('Erro ao buscar servicos de um  fornecedor por id', e, s);
      throw DatabaseException(message: e.message, exception: e);
    } finally {
      await conn.close();
    }
  }

  @override
  Future<bool> checkUserEmailExists(String email) async {
    late final MySqlConnection conn;

    try {
      conn = await _connection.openConnection();
      final result = await conn.query('''
        SELECT COUNT(*) FROM usuario WHERE email = ?
      ''', [email]);
      return result.first['COUNT(*)'] == 1;
    } on MySqlException catch (e, s) {
      _log.error('Erro ao verificar email existente', e, s);
      throw DatabaseException(message: e.message, exception: e);
    } finally {
      await conn.close();
    }
  }

  @override
  Future<int> saveSupplier(Supplier supplier) async {
    late final MySqlConnection conn;

    try {
      conn = await _connection.openConnection();

      final result = await conn.query('''
        INSERT INTO fornecedor (nome, logo, endereco, telefone, latlng, categorias_fornecedor_id)
        VALUES (?, ?, ?, ?, ST_GeomFromText(?), ?)
      ''', [
        supplier.name,
        supplier.logo,
        supplier.address,
        supplier.phone,
        'POINT(${supplier.lat ?? 0} ${supplier.lng ?? 0})',
        supplier.category?.id,
      ]);
      return result.insertId!;
    } on MySqlException catch (e, s) {
      _log.error('Erro ao cadastrar novo fornecedor', e, s);
      throw DatabaseException(message: e.message, exception: e);
    } finally {
      await conn.close();
    }
  }

  @override
  Future<Supplier> update(Supplier supplier) async {
    late final MySqlConnection conn;

    try {
      conn = await _connection.openConnection();
      await conn.query('''
        UPDATE fornecedor
        SET nome = ?, logo = ?, endereco = ?, telefone = ?, latlng = ST_GeomFromText(?), categorias_fornecedor_id = ?
        WHERE id = ?
      ''', [
        supplier.name,
        supplier.logo,
        supplier.address,
        supplier.phone,
        'POINT(${supplier.lat ?? 0} ${supplier.lng ?? 0})',
        supplier.category?.id,
        supplier.id,
      ]);
      Category? category;
      if (supplier.category?.id != null) {
        final resultCategory = await conn.query(
          'select * from categorias_fornecedor where id = ?',
          [supplier.category?.id],
        );
        category = Category(
          id: resultCategory.first['id'],
          name: resultCategory.first['nome_categoria'],
          type: resultCategory.first['tipo_categoria'],
        );
      }

      return supplier.copyWith(category: category);
    } on MySqlException catch (e, s) {
      _log.error('Erro ao atualizar fornecedor', e, s);
      throw DatabaseException(message: e.message, exception: e);
    } finally {
      await conn.close();
    }
  }
}
