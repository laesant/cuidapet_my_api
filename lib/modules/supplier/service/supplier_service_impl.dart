import 'package:cuidapet_my_api/modules/supplier/data/supplier_repository.dart';
import 'package:injectable/injectable.dart';

import './supplier_service.dart';

@LazySingleton(as: SupplierService)
class SupplierServiceImpl implements SupplierService {
  final SupplierRepository _repository;

  const SupplierServiceImpl({required SupplierRepository repository})
      : _repository = repository;
}
