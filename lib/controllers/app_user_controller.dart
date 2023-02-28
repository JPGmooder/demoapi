import 'dart:io';

import 'package:backend/models/db/user_model.dart';
import 'package:backend/models/service/logger.dart';
import 'package:backend/utils/app_utils.dart';
import 'package:conduit/conduit.dart';

class AppUserController extends ResourceController {
  AppUserController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getProfileById(
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try {
      final userId = AppsUtils.getIdFromHeader(header);
      var currentUser = await context.fetchObjectWithID<User>(userId);

      if (currentUser == null) {
        return Response.serverError(body: "Пользователь не найден");
      }

      currentUser
          .removePropertiesFromBackingMap(['refreshToken', 'accessToken']);

      return Response.ok(currentUser.asMap());
    } on QueryException catch (e) {
      return Response.serverError(body: e.message);
    }
  }

  @Operation.post()
  Future<Response> updateUser(@Bind.body() User user,
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try {
      final id = AppsUtils.getIdFromHeader(header);

      final foundedUser = await context.fetchObjectWithID<User>(id);

      if (foundedUser == null) {
        return Response.serverError(body: "Пользователь не найден");
      }
      String? hashPassword;
      if (user.password != null && user.password!.isNotEmpty) {
        var salt = generateRandomSalt();
        hashPassword = generatePasswordHash(user.password!, salt);
      }

      final qUpdateUser = Query<User>(context)
        ..where((x) => x.id).equalTo(id)
        ..values.userName = user.userName ?? foundedUser.userName
        ..values.email = user.email ?? foundedUser.email;

      if (hashPassword != null) {
        qUpdateUser.values.hashedPassword = hashPassword;
      }
      await qUpdateUser.updateOne();

      final findUser = await context.fetchObjectWithID<User>(id);

      findUser!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);
      LogsInsuranse.writeLog(
          description: "Обновление пользователя",
          owner: foundedUser,
          context: context);
      return Response.ok(findUser.asMap());
    } on QueryException catch (e) {
      return Response.serverError(body: e.message);
    }
  }
}
