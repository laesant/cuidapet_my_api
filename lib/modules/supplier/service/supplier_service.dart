import 'package:cuidapet_my_api/dtos/supplier_near_by_me_dto.dart';

abstract interface class SupplierService {
  Future<List<SupplierNearByMeDto>> findNearByMe(double lat, double lng);
}
