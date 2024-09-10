import 'package:cuidapet_my_api/dtos/supplier_near_by_me_dto.dart';
import 'package:cuidapet_my_api/entities/supplier.dart';
import 'package:cuidapet_my_api/entities/supplier_service_entity.dart';
import 'package:cuidapet_my_api/modules/supplier/view_models/create_supplier_user_model.dart';

abstract interface class SupplierService {
  Future<List<SupplierNearByMeDto>> findNearByMe(double lat, double lng);
  Future<Supplier?> findById(int id);
  Future<List<SupplierServiceEntity>> findServicesBySupplierId(int supplierId);
  Future<bool> checkUserEmailExists(String email);
  Future<void> createSupplierUser(CreateSupplierUserModel model);
}
