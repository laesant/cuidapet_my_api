import 'package:cuidapet_my_api/dtos/supplier_near_by_me_dto.dart';
import 'package:cuidapet_my_api/entities/supplier.dart';
import 'package:cuidapet_my_api/modules/supplier/data/supplier_repository.dart';
import 'package:injectable/injectable.dart';

import './supplier_service.dart';

@LazySingleton(as: SupplierService)
class SupplierServiceImpl implements SupplierService {
  final SupplierRepository _repository;
  static const distance = 5;

  const SupplierServiceImpl({required SupplierRepository repository})
      : _repository = repository;

  @override
  Future<List<SupplierNearByMeDto>> findNearByMe(double lat, double lng) =>
      _repository.findNearByPosition(lat, lng, distance);

  @override
  Future<Supplier?> findById(int id) => _repository.findById(id);
}
