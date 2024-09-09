// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../modules/categories/controller/categories_controller.dart' as _i55;
import '../../modules/categories/data/categories_repository.dart' as _i537;
import '../../modules/categories/data/categories_repository_impl.dart' as _i772;
import '../../modules/categories/service/categories_service.dart' as _i805;
import '../../modules/categories/service/categories_service_impl.dart'
    as _i1053;
import '../../modules/user/controller/auth_controller.dart' as _i477;
import '../../modules/user/controller/user_controller.dart' as _i983;
import '../../modules/user/data/i_user_repository.dart' as _i872;
import '../../modules/user/data/i_user_repository_impl.dart' as _i1014;
import '../../modules/user/service/i_user_service.dart' as _i610;
import '../../modules/user/service/i_user_service_impl.dart' as _i705;
import '../database/i_database_connection.dart' as _i77;
import '../database/i_database_connection_impl.dart' as _i795;
import '../logger/i_logger.dart' as _i742;
import 'database_connection_configuration.dart' as _i32;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i55.CategoriesController>(() => _i55.CategoriesController());
    gh.lazySingleton<_i537.CategoriesRepository>(
        () => _i772.CategoriesRepositoryImpl());
    gh.lazySingleton<_i77.IDatabaseConnection>(() =>
        _i795.IDatabaseConnectionImpl(
            gh<_i32.DatabaseConnectionConfiguration>()));
    gh.lazySingleton<_i805.CategoriesService>(
        () => _i1053.CategoriesServiceImpl());
    gh.lazySingleton<_i872.IUserRepository>(() => _i1014.IUserRepositoryImpl(
          connection: gh<_i77.IDatabaseConnection>(),
          log: gh<_i742.ILogger>(),
        ));
    gh.lazySingleton<_i610.IUserService>(() => _i705.IUserServiceImpl(
          userRepository: gh<_i872.IUserRepository>(),
          log: gh<_i742.ILogger>(),
        ));
    gh.factory<_i477.AuthController>(() => _i477.AuthController(
          userService: gh<_i610.IUserService>(),
          log: gh<_i742.ILogger>(),
        ));
    gh.factory<_i983.UserController>(() => _i983.UserController(
          userService: gh<_i610.IUserService>(),
          log: gh<_i742.ILogger>(),
        ));
    return this;
  }
}
