import 'dart:convert';

import 'package:cuidapet_my_api/application/helpers/jwt_helper.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/application/middlewares/middlewares.dart';
import 'package:cuidapet_my_api/application/middlewares/security/security_skip_url.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/shelf.dart';

class SecurityMiddleware extends Middlewares {
  final ILogger _log;
  final skipUrl = <SecuritySkipUrl>[
    SecuritySkipUrl(url: '/auth/', method: 'POST'),
    SecuritySkipUrl(url: '/auth/register', method: 'POST'),
    SecuritySkipUrl(url: '/suppliers/user', method: 'GET'),
  ];

  SecurityMiddleware(this._log);

  @override
  Future<Response> execute(Request request) async {
    if (skipUrl.contains(
        SecuritySkipUrl(url: '/${request.url.path}', method: request.method))) {
      return innerHandler(request);
    }

    final authHeader = request.headers['authorization'];

    if (authHeader == null || authHeader.isEmpty) {
      _log.error('SecurityMiddleware: Authorization header is missing');
      return Response.forbidden(
          jsonEncode({'message': 'Authorization header is missing'}));
    }

    final authHeaderContent = authHeader.split(' ');

    if (authHeaderContent[0] != 'Bearer') {
      _log.error('SecurityMiddleware: Invalid authorization header');
      return Response.forbidden(
          jsonEncode({'message': 'Invalid authorization header'}));
    }

    try {
      final authorizationToken = authHeaderContent[1];
      final claim = JwtHelper.getClaim(authorizationToken);

      if (request.url.path != 'auth/refresh') {
        claim.validate();
      }

      final claimMap = claim.toJson();
      final userId = claimMap['sub'];
      final supplierId = claimMap['supplier'];

      if (userId == null) {
        throw JwtException.invalidToken;
      }

      final securityHeaders = {
        'user': userId,
        'supplier': supplierId,
        'access_token': authorizationToken,
      };
      return innerHandler(request.change(headers: securityHeaders));
    } on JwtException catch (e, s) {
      _log.error('Erro ao validar token JWT', e, s);
      return Response.forbidden(jsonEncode({}));
    } catch (e, s) {
      _log.error('Internal Server Error', e, s);
      return Response.forbidden(jsonEncode({}));
    }
  }
}
