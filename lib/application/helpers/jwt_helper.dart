import 'package:cuidapet_my_api/application/config/application_config.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class JwtHelper {
  JwtHelper._();
  static final String _jwtSecret = ApplicationConfig.env!['JWT_SECRET'] ??
      ApplicationConfig.env!['jwtSecret']!;

  static String generateJWT(int userId, int? supplierId) =>
      'Bearer ${issueJwtHS256(JwtClaim(
            issuer: 'cuidapet',
            subject: userId.toString(),
            expiry: DateTime.now().add(const Duration(days: 1)),
            notBefore: DateTime.now(),
            issuedAt: DateTime.now(),
            otherClaims: {
              'supplier': supplierId,
            },
            maxAge: const Duration(days: 1),
          ), _jwtSecret)}';

  static JwtClaim getClaim(String token) =>
      verifyJwtHS256Signature(token, _jwtSecret);

  static String refreshToken(String accessToken) {
    final expiry =
        int.parse(ApplicationConfig.env!['refresh_token_expire_days']!);
    final notBefore =
        int.parse(ApplicationConfig.env!['refresh_token_not_before_hours']!);

    return 'Bearer ${issueJwtHS256(JwtClaim(
          issuer: accessToken,
          subject: 'RefreshToken',
          expiry: DateTime.now().add(Duration(days: expiry)),
          notBefore: DateTime.now().add(Duration(hours: notBefore)),
          issuedAt: DateTime.now(),
        ), _jwtSecret)}';
  }
}
