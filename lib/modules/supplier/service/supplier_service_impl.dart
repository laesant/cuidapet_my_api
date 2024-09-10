import 'package:cuidapet_my_api/dtos/supplier_near_by_me_dto.dart';
import 'package:cuidapet_my_api/entities/category.dart';
import 'package:cuidapet_my_api/entities/supplier.dart';
import 'package:cuidapet_my_api/entities/supplier_service_entity.dart';
import 'package:cuidapet_my_api/modules/supplier/data/supplier_repository.dart';
import 'package:cuidapet_my_api/modules/supplier/view_models/create_supplier_user_model.dart';
import 'package:cuidapet_my_api/modules/user/service/i_user_service.dart';
import 'package:cuidapet_my_api/modules/user/view_models/user_save_input_model.dart';
import 'package:injectable/injectable.dart';

import './supplier_service.dart';

@LazySingleton(as: SupplierService)
class SupplierServiceImpl implements SupplierService {
  final SupplierRepository _repository;
  final IUserService _userService;
  static const distance = 5;

  const SupplierServiceImpl(
      {required SupplierRepository repository,
      required IUserService userService})
      : _repository = repository,
        _userService = userService;

  @override
  Future<List<SupplierNearByMeDto>> findNearByMe(double lat, double lng) =>
      _repository.findNearByPosition(lat, lng, distance);

  @override
  Future<Supplier?> findById(int id) => _repository.findById(id);

  @override
  Future<List<SupplierServiceEntity>> findServicesBySupplierId(
          int supplierId) =>
      _repository.findServicesBySupplierId(supplierId);

  @override
  Future<bool> checkUserEmailExists(String email) =>
      _repository.checkUserEmailExists(email);

  @override
  Future<void> createSupplierUser(CreateSupplierUserModel model) async {
    final supplierId = await _repository.saveSupplier(Supplier(
      name: model.supplierName,
      category: Category(id: model.category),
    ));

    await _userService.createUser(UserSaveInputModel(
      email: model.email,
      password: model.password,
      supplierId: supplierId,
    ));
  }
}
