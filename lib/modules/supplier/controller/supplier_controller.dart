import 'dart:async';
import 'dart:convert';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/modules/supplier/service/supplier_service.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'supplier_controller.g.dart';

@Injectable()
class SupplierController {
  final SupplierService _supplierService;
  final ILogger _log;

  const SupplierController(
      {required SupplierService supplierService, required ILogger log})
      : _supplierService = supplierService,
        _log = log;

  @Route.get('/')
  Future<Response> findNearByMe(Request request) async {
    try {
      final lat = double.tryParse(request.url.queryParameters['lat'] ?? '');
      final lng = double.tryParse(request.url.queryParameters['lng'] ?? '');
      if (lat == null || lng == null) {
        return Response.badRequest(
            body: jsonEncode({'message': 'Parâmetros inválidos'}));
      }
      final suppliers = await _supplierService.findNearByMe(lat, lng);
      final result = suppliers
          .map((e) => {
                'id': e.id,
                'name': e.name,
                'logo': e.logo,
                'distance': e.distance,
                'category': e.categoryId,
              })
          .toList();
      return Response.ok(jsonEncode(result));
    } catch (e, s) {
      _log.error('Erro ao buscar fornecedores perto de mim', e, s);
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao buscar fornecedores'}));
    }
  }

  Router get router => _$SupplierControllerRouter(this);
}
