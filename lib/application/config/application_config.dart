import 'package:dotenv/dotenv.dart';

class ApplicationConfig {
  Future<void> loadConfigApplication() async {
    var env = _loadEnv();
    print(env['url_database']);
  }

  DotEnv _loadEnv() => DotEnv(includePlatformEnvironment: true)..load();
}
