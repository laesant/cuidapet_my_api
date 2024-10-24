import 'package:cuidapet_my_api/application/config/database_connection_configuration.dart';
import 'package:cuidapet_my_api/application/config/service_locator_config.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/application/logger/i_logger_impl.dart';
import 'package:cuidapet_my_api/application/routers/router_configure.dart';
import 'package:dotenv/dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:shelf_router/shelf_router.dart';

class ApplicationConfig {
  static late DotEnv env;
  Future<void> loadConfigApplication(Router router) async {
    loadEnv();
    _loadDatabaseConfig(env);
    _configLogger();
    _loadDependencies();
    _loadRoutersConfigure(router);
  }

  static void loadEnv() =>
      env = DotEnv(includePlatformEnvironment: true)..load();

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

  void _loadRoutersConfigure(Router router) =>
      RouterConfigure(router).configure();
}
