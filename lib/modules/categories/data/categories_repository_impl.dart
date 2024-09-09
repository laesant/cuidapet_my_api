import 'package:injectable/injectable.dart';

import './categories_repository.dart';

@LazySingleton(as: CategoriesRepository)
class CategoriesRepositoryImpl implements CategoriesRepository {}
