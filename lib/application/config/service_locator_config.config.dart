// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../database/i_database_connection.dart' as _i77;
import '../database/i_database_connection_impl.dart' as _i795;
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
    gh.lazySingleton<_i77.IDatabaseConnection>(() =>
        _i795.IDatabaseConnectionImpl(
            gh<_i32.DatabaseConnectionConfiguration>()));
    return this;
  }
}
