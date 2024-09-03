import 'dart:io';

import 'package:cuidapet_my_api/application/config/application_config.dart';
import 'package:cuidapet_my_api/application/middlewares/cors/cors_middlewares.dart';
import 'package:cuidapet_my_api/application/middlewares/default_content_type/default_content_type.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  final router = Router();
  final appConfig = ApplicationConfig();
  appConfig.loadConfigApplication(router);

  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(CorsMiddlewares().handler)
      .addMiddleware(DefaultContentType().handler)
      .addMiddleware(logRequests())
      .addHandler(router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
