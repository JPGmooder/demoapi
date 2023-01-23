import 'package:backend/models/db/logger_model.dart';
import 'package:backend/models/db/user_model.dart';
import 'package:conduit/conduit.dart';

abstract class LogsInsuranse {
 static Future<void> writeLog(
          {required String description,
          required User owner,
          required ManagedContext context}) async =>
      await context.transaction(
          (transaction) async => await (Query<LoggerEntity>(transaction)
                ..values.owner = owner
                ..values.operationDate = DateTime.now()
                ..values.description = description)
              .insert());

}
