import 'dart:async';
import 'dart:convert';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/entities/supplier.dart';
import 'package:cuidapet_my_api/modules/supplier/service/supplier_service.dart';
import 'package:cuidapet_my_api/modules/supplier/view_models/create_supplier_user_model.dart';
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

  @Route.get('/<id|[0-9]+>')
  Future<Response> findById(Request request, String id) async {
    final supplier = await _supplierService.findById(int.parse(id));
    if (supplier == null) {
      return Response.ok(jsonEncode({}));
    }
    return Response.ok(_supplierMapper(supplier));
  }

  @Route.get('/<supplierId|[0-9]+>/services')
  Future<Response> findServicesBySupplierId(
      Request request, String supplierId) async {
    try {
      final supplierServices = await _supplierService
          .findServicesBySupplierId(int.parse(supplierId));

      return Response.ok(jsonEncode(supplierServices
          .map((e) => {
                'id': e.id,
                'supplierId': e.supplierId,
                'name': e.name,
                'price': e.price,
              })
          .toList()));
    } catch (e, s) {
      _log.error('Erro ao buscar serviços de um fornecedor', e, s);
      return Response.internalServerError(
        body: jsonEncode({'message': 'Erro ao buscar serviços'}),
      );
    }
  }

  @Route.get('/user')
  Future<Response> checkUserExists(Request request) async {
    final email = request.url.queryParameters['email'];
    if (email == null) {
      return Response.badRequest(
          body: jsonEncode({'message': 'E-mail obrigatório'}));
    }
    final isEmailExists = await _supplierService.checkUserEmailExists(email);
    return isEmailExists ? Response(200) : Response(204);
    //  return Response.ok(jsonEncode(isEmailExists));
  }

  @Route.post('/user')
  Future<Response> createNewUser(Request request) async {
    try {
      await _supplierService.createSupplierUser(
          CreateSupplierUserModel(await request.readAsString()));
      return Response.ok(
          jsonEncode({'message': 'Usuário cadastrado com sucesso'}));
    } catch (e, s) {
      _log.error('Erro ao cadastrar usuário', e, s);
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao cadastrar usuário'}));
    }
  }

  String _supplierMapper(Supplier supplier) {
    return jsonEncode({
      'id': supplier.id,
      'name': supplier.name,
      'logo': supplier.logo,
      'address': supplier.address,
      'phone': supplier.phone,
      'lat': supplier.lat,
      'lng': supplier.lng,
      'category': {
        'ind': supplier.category?.id,
        'name': supplier.category?.name,
        'type': supplier.category?.type,
      },
    });
  }

  Router get router => _$SupplierControllerRouter(this);
}
