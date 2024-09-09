import 'package:cuidapet_my_api/entities/category.dart';

abstract interface class CategoriesRepository {
  Future<List<Category>> findAll();
}
