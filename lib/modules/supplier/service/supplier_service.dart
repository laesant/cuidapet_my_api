import 'package:cuidapet_my_api/dtos/supplier_near_by_me_dto.dart';
import 'package:cuidapet_my_api/entities/supplier.dart';

abstract interface class SupplierService {
  Future<List<SupplierNearByMeDto>> findNearByMe(double lat, double lng);
  Future<Supplier?> findById(int id);
}
