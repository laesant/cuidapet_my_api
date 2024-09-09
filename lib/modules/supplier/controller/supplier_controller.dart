import 'dart:async';
import 'dart:convert';
import 'package:cuidapet_my_api/modules/supplier/service/supplier_service.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'supplier_controller.g.dart';

@Injectable()
class SupplierController {
  final SupplierService _supplierService;

  const SupplierController({required SupplierService supplierService})
      : _supplierService = supplierService;

  @Route.get('/')
  Future<Response> find(Request request) async {
    return Response.ok(jsonEncode(''));
  }

  Router get router => _$SupplierControllerRouter(this);
}
