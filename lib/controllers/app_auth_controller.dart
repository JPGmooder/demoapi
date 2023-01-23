import 'dart:io';

import 'package:backend/models/db/user_model.dart';
import 'package:backend/models/service/logger.dart';
import 'package:backend/models/service/response_model.dart';
import 'package:backend/utils/app_response.dart';
import 'package:backend/utils/app_utils.dart';
import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AppAuthController extends ResourceController {
  ManagedContext context;

  AppAuthController(this.context);

  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.password!.isEmpty || user.email!.isEmpty) {
      return AppResponse.serverError(
          "Auth error", "Пользователь не найден, повторите попытку");
    }

    try {
      var query = Query<User>(context)
        ..where((x) => x.email).equalTo(user.email)
        ..returningProperties((x) => [x.id, x.salt, x.hashedPassword]);
      var findedUser = await query.fetchOne();
      if (findedUser == null) {
        return AppResponse.serverError(
            "Auth error", "Пользователь не найден, повторите попытку");
      }

      if (findedUser.hashedPassword !=
          generatePasswordHash(user.password!, findedUser.salt!)) {
        return AppResponse.serverError(
            "Auth error", "Пользователь не найден, повторите попытку");
      }
      var userToReturn = await context.fetchObjectWithID<User>(findedUser.id);

      LogsInsuranse.writeLog(
          description: "Авторизация", owner: findedUser, context: context);

      return Response.ok(userToReturn!.backing.contents);
    } on QueryException catch (e) {
      return Response.serverError(body: e.message);
    }
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.password!.isEmpty ||
        user.email!.isEmpty ||
        user.userName!.isEmpty) {
      return AppResponse.serverError(
          "Sign error", "Необходимые поля не заполнены, повторите попытку");
    }
    var salt = generateRandomSalt();
    final hashPassword = generatePasswordHash(user.password!, salt);

    try {
      late final int id;
      await context.transaction<User>((transaction) async {
        final qCreatedUser = Query<User>(transaction)
          ..values.userName = user.userName
          ..values.email = user.email
          ..values.salt = salt
          ..values.hashedPassword = hashPassword;
        final createdUser = await qCreatedUser.insert();
        id = createdUser.id!;
        _updateTokens(id, transaction);
        return createdUser;
      });

      final userData = await context.fetchObjectWithID<User>(id);
      LogsInsuranse.writeLog(
          description: "Регистрация", owner: userData!, context: context);
      return Response.ok(userData.backing.contents);
    } on QueryException catch (e) {
      return Response.serverError(body: e.message);
    }
  }

  @Operation.post('refresh')
  Future<Response> refreshToken(
      @Bind.path("refresh") String refreshToken) async {
    try {
      final id = AppsUtils.getIdFromJwtToken(refreshToken);

      final user = await context.fetchObjectWithID<User>(id);

      if (user!.refreshTokent != refreshToken) {
        return Response.unauthorized(body: 'Invalid token');
      }

      _updateTokens(id, context);

      return Response.ok(user.backing.contents);
    } on QueryException catch (e) {
      return Response.serverError(body: e.message);
    }
  }

  void _updateTokens(int id, ManagedContext transaction) async {
    final Map<String, String> tokens = _getTokens(id);

    final qUpdateTokens = Query<User>(transaction)
      ..where((x) => x.id).equalTo(id)
      ..values.accesTokent = tokens['access']
      ..values.refreshTokent = tokens['refresh'];
    await qUpdateTokens.updateOne();
  }

  Map<String, String> _getTokens(int id) {
    final key = Platform.environment['SECRET_KEY'] ?? "SECRET_KEY";

    final accessClaimSet =
        JwtClaim(maxAge: const Duration(hours: 1), otherClaims: {'id': id});
    final refrechClaimSet = JwtClaim(otherClaims: {'id': id});
    final tokens = <String, String>{};

    tokens['access'] = issueJwtHS256(accessClaimSet, key);
    tokens['refresh'] = issueJwtHS256(refrechClaimSet, key);
    return tokens;
  }
}
