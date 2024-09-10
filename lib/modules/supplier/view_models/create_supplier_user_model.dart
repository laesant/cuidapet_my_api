import 'package:cuidapet_my_api/application/helpers/request_mapping.dart';

class CreateSupplierUserModel extends RequestMapping {
  late String supplierName;
  late String email;
  late String password;
  late int category;
  CreateSupplierUserModel(super.data);

  @override
  void map() {
    supplierName = data['supplier_name'];
    email = data['email'];
    password = data['password'];
    category = int.parse(data['category_id']);
  }
}
