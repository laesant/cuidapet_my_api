import 'dart:async';
import 'dart:convert';
import 'package:cuidapet_my_api/modules/categories/service/categories_service.dart';
import 'package:injectable/injectable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'categories_controller.g.dart';

@Injectable()
class CategoriesController {
  final CategoriesService _categoriesService;

  const CategoriesController({required CategoriesService categoriesService})
      : _categoriesService = categoriesService;
  @Route.get('/')
  Future<Response> findAll(Request request) async {
    try {
      final categories = await _categoriesService.findAll();
      return Response.ok(jsonEncode(categories
          .map((e) => {
                'id': e.id,
                'nome': e.name,
                'tipo': e.type,
              })
          .toList()));
    } catch (_) {
      return Response.internalServerError(
          body: jsonEncode({'message': 'Erro ao buscar categorias'}));
    }
  }

  Router get router => _$CategoriesControllerRouter(this);
}
