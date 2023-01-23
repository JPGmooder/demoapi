import 'dart:async';
import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AppTokencontroller extends Controller {
  @override
  FutureOr<RequestOrResponse?> handle(Request request) {
    try {
      final header = request.raw.headers.value(HttpHeaders.authorizationHeader);
      final token = const AuthorizationBearerParser().parse(header);
      final JwtClaim = verifyJwtHS256Signature(
          token ?? '', Platform.environment['SECRET_KEY'] ?? "SECRET_KEY");
      JwtClaim.validate();
      return request;
    } on JwtException catch (e) {
      return Response.serverError(body: e.message);
    }
  }
}
