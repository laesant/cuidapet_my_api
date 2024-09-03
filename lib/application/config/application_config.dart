import 'package:cuidapet_my_api/application/config/database_connection_configuration.dart';
import 'package:cuidapet_my_api/application/config/service_locator_config.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/application/logger/i_logger_impl.dart';
import 'package:dotenv/dotenv.dart';
import 'package:get_it/get_it.dart';

class ApplicationConfig {
  Future<void> loadConfigApplication() async {
    var env = _loadEnv();
    _loadDatabaseConfig(env);
    _configLogger();
    _loadDependencies();
  }

  DotEnv _loadEnv() => DotEnv(includePlatformEnvironment: true)..load();

  void _loadDatabaseConfig(DotEnv env) {
    final databaseConfig = DatabaseConnectionConfiguration(
        host: env['DATABASE_HOST'] ?? env['databaseHost']!,
        user: env['DATABASE_USER'] ?? env['databaseUser']!,
        port: env['DATABASE_PORT'] ?? env['databasePort']!,
        password: env['DATABASE_PASSWORD'] ?? env['databasePassword']!,
        database: env['DATABASE_NAME'] ?? env['databaseName']!);

    GetIt.I.registerSingleton(databaseConfig);
  }

  void _configLogger() =>
      GetIt.I.registerLazySingleton<ILogger>(() => ILoggerImpl());

  void _loadDependencies() => configureDependencies();
}
