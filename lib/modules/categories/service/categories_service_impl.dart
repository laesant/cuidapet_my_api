import 'package:cuidapet_my_api/entities/category.dart';
import 'package:cuidapet_my_api/modules/categories/data/categories_repository.dart';
import 'package:injectable/injectable.dart';

import './categories_service.dart';

@LazySingleton(as: CategoriesService)
class CategoriesServiceImpl implements CategoriesService {
  final CategoriesRepository _repository;

  const CategoriesServiceImpl({required CategoriesRepository repository})
      : _repository = repository;
  @override
  Future<List<Category>> findAll() => _repository.findAll();
}
