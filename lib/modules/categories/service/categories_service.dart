import 'package:cuidapet_my_api/entities/category.dart';

abstract interface class CategoriesService {
  Future<List<Category>> findAll();
}
