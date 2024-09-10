import 'package:cuidapet_my_api/application/helpers/request_mapping.dart';

class SupplierUpdateInputModel extends RequestMapping {
  int supplierId;
  late String name;
  late String logo;
  late String address;
  late String phone;
  late double lat;
  late double lng;
  late int categoryId;
  SupplierUpdateInputModel(
    super.data, {
    required this.supplierId,
  });

  @override
  void map() {
    name = data['name'];
    logo = data['logo'];
    address = data['address'];
    phone = data['phone'];
    lat = data['lat'];
    lng = data['lng'];
    categoryId = data['category'];
  }
}
