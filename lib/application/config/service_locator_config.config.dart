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
import '../../modules/chat/controller/chat_controller.dart' as _i194;
import '../../modules/chat/data/chat_repository.dart' as _i199;
import '../../modules/chat/data/chat_repository_impl.dart' as _i482;
import '../../modules/chat/service/chat_service.dart' as _i51;
import '../../modules/chat/service/chat_service_impl.dart' as _i931;
import '../../modules/schedules/controller/schedule_controller.dart' as _i436;
import '../../modules/schedules/data/schedule_repository.dart' as _i451;
import '../../modules/schedules/data/schedule_repository_impl.dart' as _i6;
import '../../modules/schedules/service/schedule_service.dart' as _i541;
import '../../modules/schedules/service/schedule_service_impl.dart' as _i26;
import '../../modules/supplier/controller/supplier_controller.dart' as _i331;
import '../../modules/supplier/data/supplier_repository.dart' as _i151;
import '../../modules/supplier/data/supplier_repository_impl.dart' as _i998;
import '../../modules/supplier/service/supplier_service.dart' as _i977;
import '../../modules/supplier/service/supplier_service_impl.dart' as _i1058;
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
    gh.factory<_i194.ChatController>(() => _i194.ChatController());
    gh.lazySingleton<_i51.ChatService>(() => _i931.ChatServiceImpl());
    gh.lazySingleton<_i77.IDatabaseConnection>(() =>
        _i795.IDatabaseConnectionImpl(
            gh<_i32.DatabaseConnectionConfiguration>()));
    gh.lazySingleton<_i537.CategoriesRepository>(
        () => _i772.CategoriesRepositoryImpl(
              connection: gh<_i77.IDatabaseConnection>(),
              log: gh<_i742.ILogger>(),
            ));
    gh.lazySingleton<_i199.ChatRepository>(() => _i482.ChatRepositoryImpl());
    gh.lazySingleton<_i805.CategoriesService>(() =>
        _i1053.CategoriesServiceImpl(
            repository: gh<_i537.CategoriesRepository>()));
    gh.lazySingleton<_i451.ScheduleRepository>(() => _i6.ScheduleRepositoryImpl(
          connection: gh<_i77.IDatabaseConnection>(),
          log: gh<_i742.ILogger>(),
        ));
    gh.lazySingleton<_i151.SupplierRepository>(
        () => _i998.SupplierRepositoryImpl(
              connection: gh<_i77.IDatabaseConnection>(),
              log: gh<_i742.ILogger>(),
            ));
    gh.lazySingleton<_i541.ScheduleService>(() =>
        _i26.ScheduleServiceImpl(repository: gh<_i451.ScheduleRepository>()));
    gh.factory<_i55.CategoriesController>(() => _i55.CategoriesController(
        categoriesService: gh<_i805.CategoriesService>()));
    gh.lazySingleton<_i872.IUserRepository>(() => _i1014.IUserRepositoryImpl(
          connection: gh<_i77.IDatabaseConnection>(),
          log: gh<_i742.ILogger>(),
        ));
    gh.lazySingleton<_i610.IUserService>(() => _i705.IUserServiceImpl(
          userRepository: gh<_i872.IUserRepository>(),
          log: gh<_i742.ILogger>(),
        ));
    gh.factory<_i436.ScheduleController>(() => _i436.ScheduleController(
          scheduleService: gh<_i541.ScheduleService>(),
          log: gh<_i742.ILogger>(),
        ));
    gh.lazySingleton<_i977.SupplierService>(() => _i1058.SupplierServiceImpl(
          repository: gh<_i151.SupplierRepository>(),
          userService: gh<_i610.IUserService>(),
        ));
    gh.factory<_i331.SupplierController>(() => _i331.SupplierController(
          supplierService: gh<_i977.SupplierService>(),
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
