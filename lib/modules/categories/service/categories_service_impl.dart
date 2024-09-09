import 'package:injectable/injectable.dart';

import './categories_service.dart';

@LazySingleton(as: CategoriesService)
class CategoriesServiceImpl implements CategoriesService {}
