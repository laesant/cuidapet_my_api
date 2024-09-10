import 'package:cuidapet_my_api/dtos/supplier_near_by_me_dto.dart';
import 'package:cuidapet_my_api/entities/supplier.dart';
import 'package:cuidapet_my_api/entities/supplier_service_entity.dart';

abstract interface class SupplierRepository {
  Future<List<SupplierNearByMeDto>> findNearByPosition(
      double lat, double lng, int distance);
  Future<Supplier?> findById(int id);
  Future<List<SupplierServiceEntity>> findServicesBySupplierId(int supplierId);
  Future<bool> checkUserEmailExists(String email);
  Future<int> saveSupplier(Supplier supplier);
}
