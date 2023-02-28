import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:backend/models/db/user_model.dart';
import 'package:backend/models/service/logger.dart';
import 'package:backend/utils/app_response.dart';
import 'package:backend/utils/app_utils.dart';
import 'package:conduit/conduit.dart';

class AppOperationController extends ResourceController {
  AppOperationController(this.context);
  ManagedContext context;

  @Operation.get()
  Future<Response> searchOperations(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      {@Bind.query('name') String? cityName,
      @Bind.query('isHidden') int? isHidden}) async {
    var id = AppsUtils.getIdFromHeader(header);

    var currentOperations = await (Query<BankOperation>(context)
          ..returningProperties((x) => [
                x.date,
                x.cathegory,
                x.description,
                x.name,
                x.summ,
                x.isVisible,
                x.owner!.userName
              ])
          ..where((x) => x.owner!.id).equalTo(id)
          ..where((x) => x.isVisible).equalTo(isHidden == null)
          ..where((x) => x.name).contains(cityName ?? '')
          ..sortBy((x) => x.date, QuerySortOrder.descending))
        .fetch();
    if (currentOperations.isEmpty) {
      return Response.noContent();
    }
    var listToReturn = currentOperations.map((e) => e.asMap()).toList();
    var currentUser = await context.fetchObjectWithID<User>(id);
    LogsInsuranse.writeLog(
        description: cityName == null
            ? "Осуществление вывода всех операций"
            : "Осуществление поиска операций по ключевому слову '$cityName'",
        owner: currentUser!,
        context: context);
    return Response.ok(listToReturn);
  }

  @Operation.get("page")
  Future<Response> getOperations(@Bind.path("page") int page,
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    var id = AppsUtils.getIdFromHeader(header);
    var currentOperations = await (Query<BankOperation>(context)
          ..returningProperties((x) => [
                x.date,
                x.cathegory,
                x.description,
                x.name,
                x.summ,
                x.owner!.userName
              ])
          ..where((x) => x.isVisible).equalTo(true)
          ..where((x) => x.owner!.id).equalTo(id)
          ..sortBy((x) => x.date, QuerySortOrder.descending)
          ..offset = page * 20
          ..fetchLimit = 20)
        .fetch();
    if (currentOperations.isEmpty) {
      return Response.noContent();
    }
    var listToReturn = currentOperations.map((e) => e.asMap()).toList();
    var currentUser = await context.fetchObjectWithID<User>(id);
    LogsInsuranse.writeLog(
        description: "Осуществление вывода страницы $page операций",
        owner: currentUser!,
        context: context);
    return Response.ok(listToReturn);
  }

  @Operation.post()
  Future<Response> addOperation(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() BankOperation operation,
  ) async {
    try {
      if (operation.summ! <= 0 ||
          operation.name!.isEmpty ||
          operation.cathegory!.isEmpty ||
          operation.date!.isAfter(DateTime.now()) ||
          operation.description!.isEmpty) {
        return Response.serverError(
            body: "Операция имеет не верный формат, повторите попытку");
      }
      var id = AppsUtils.getIdFromHeader(header);
      var poster = await context.fetchObjectWithID<User>(id);
      if (poster == null) {
        return Response.serverError(
            body: "У вас нет доступа на совершение данной опперации");
      }

      var shtukaToDisplay = await context.transaction<BankOperation>(
          (transaction) async => await (Query<BankOperation>(transaction)
                ..where((x) => x.isVisible).equalTo(true)
                ..values.date = operation.date
                ..values.description = operation.description
                ..values.name = operation.name
                ..values.cathegory = operation.cathegory
                ..values.owner = poster
                ..values.summ = operation.summ)
              .insert());
      LogsInsuranse.writeLog(
          description: "Добавление операции", owner: poster, context: context);
      return Response.ok(shtukaToDisplay!.asMap());
    } on QueryException catch (e) {
      return Response.serverError(body: e.message);
    }
  }

  @Operation.put("page")
  Future<Response> updateOperation(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("page") int id,
      @Bind.body() BankOperation operation) async {
    try {
      if (operation.summ! <= 0 ||
          operation.name!.isEmpty ||
          operation.cathegory!.isEmpty ||
          operation.date!.isAfter(DateTime.now()) ||
          operation.description!.isEmpty) {
        return Response.serverError(
            body: "Операция имеет не верный формат, повторите попытку");
      }
      var userId = AppsUtils.getIdFromHeader(header);
      var poster = await context.fetchObjectWithID<User>(userId);
      if (poster == null) {
        return Response.serverError(
            body: "У вас нет доступа на совершение данной опперации");
      }

      var shtukaToDisplay =
          await context.transaction<BankOperation>((transaction) async {
        return await (Query<BankOperation>(transaction)
              ..where((x) => x.isVisible).equalTo(true)
              ..where((x) => x.id).equalTo(id)
              ..values.date = operation.date
              ..values.description = operation.description
              ..values.name = operation.name
              ..values.cathegory = operation.cathegory
              ..values.summ = operation.summ)
            .updateOne();
      });
      LogsInsuranse.writeLog(
          description: "Обновление операции №$id",
          owner: poster,
          context: context);
      return Response.ok(shtukaToDisplay!.asMap());
    } on QueryException catch (e) {
      return Response.serverError(body: e.response.body);
    }
  }

  @Operation.delete("page")
  Future<Response> deleteOperation(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("page") int id,
      {@Bind.query("logical") int? logical}) async {
    try {
      var userId = AppsUtils.getIdFromHeader(header);
      var poster = await context.fetchObjectWithID<User>(userId);
      if (poster == null) {
        return Response.serverError(
            body: "У вас нет доступа на совершение данной опперации");
      }
      await context.transaction<BankOperation>((transaction) async {
        late Future<dynamic> aboba;
        if (logical != null) {
          aboba =
              ((Query<BankOperation>(transaction)..where((x) => x.id).equalTo(id))
                    ..values.isVisible = logical == 1)
                  .updateOne();
        } else {
          aboba = (Query<BankOperation>(transaction)
                ..where((x) => x.id).equalTo(id))
              .delete();
        }

        return await aboba;
      });
      LogsInsuranse.writeLog(
          description: logical != null
              ? "Логическое ${logical == 1 ? 'восстановление' : 'удаление'} операции №$id"
              : "Удаление операции №$id",
          owner: poster,
          context: context);
      return Response.noContent();
    } on QueryException catch (e) {
      log(e.toString());
      return Response.serverError(body: e.message);
    }
  }
}
