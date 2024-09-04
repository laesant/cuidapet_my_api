import 'package:cuidapet_my_api/application/config/application_config.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class JwtHelper {
  JwtHelper._();
  static final String _jwtSecret = ApplicationConfig.env['JWT_SECRET'] ??
      ApplicationConfig.env['jwtSecret']!;

  static JwtClaim getClaim(String token) {
    return verifyJwtHS256Signature(token, _jwtSecret);
  }
}
