import 'dart:async';
import 'dart:io';

import 'package:backend/models/db/logger_model.dart';
import 'package:backend/models/db/user_model.dart';
import 'package:backend/utils/app_utils.dart';
import 'package:conduit/conduit.dart';

class AppLogController extends ResourceController {
  ManagedContext context;
  AppLogController(this.context);
  @Operation.get()
  Future<Response> loadLogs(
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    var userId = AppsUtils.getIdFromHeader(header);
    var listToDisplay =
        await context.transaction<List<LoggerEntity>>((transaction) async {
      return await (Query<LoggerEntity>(transaction)
            ..where((x) => x.owner!.id).equalTo(userId)
            ..sortBy((x) => x.operationDate, QuerySortOrder.descending))
          .fetch();
    });
    if (listToDisplay == null || listToDisplay.isEmpty) {
      return Response.noContent();
    }
    return Response.ok(listToDisplay.map((e) => e.asMap()).toList());
  }
}
