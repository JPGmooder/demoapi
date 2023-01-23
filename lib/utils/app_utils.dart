import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class AppsUtils {
  static int getIdFromJwtToken(String token) {
    try {
      final key = Platform.environment["SECRET_KEY"] ?? "SECRET_KEY";
      final jwtClaim = verifyJwtHS256Signature(token, key);

      return jwtClaim['id'];
    } catch (e) {
      rethrow;
    }
  }

  static int getIdFromHeader(String header) {
    try {
      final token = AuthorizationBearerParser().parse(header);
      return getIdFromJwtToken(token ?? '');
    } catch (e) {
      rethrow;
    }
  }
}
