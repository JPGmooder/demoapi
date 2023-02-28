import 'dart:developer';
import 'dart:io';

import 'package:backend/controllers/app_auth_controller.dart';
import 'package:backend/controllers/app_log_controller.dart';
import 'package:backend/controllers/app_operation_controller.dart';
import 'package:backend/controllers/app_token_controller.dart';
import 'package:backend/controllers/app_user_controller.dart';
import 'package:backend/models/service/response_model.dart';
import 'package:conduit/conduit.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  PostgreSQLPersistentStore _initDatabase() {
    final username = Platform.environment['DB_USERNAME'] ?? 'admin';
    final password = Platform.environment['DB_PASSWORD'] ?? 'root';
    final host = Platform.environment['DB_HOST'] ?? 'localhost';
    final port = int.parse(Platform.environment['DB_PORT'] ?? '5438');
    final databaseName = Platform.environment['DB_NAME'] ?? 'postgres';

    return PostgreSQLPersistentStore(
        username, password, host, port, databaseName);
  }

  @override
  Future prepare() {
    managedContext = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), _initDatabase());
    return super.prepare();
  }

  @override
  Controller get entryPoint {
    var currentRouter = Router();
    currentRouter
        .route("token/[:refresh]")
        .link(() => AppAuthController(managedContext));
    currentRouter
        .route('user')
        .link(AppTokencontroller.new)!
        .link(() => AppUserController(managedContext));
    currentRouter
        .route('operation/[:page]')
        .link(AppTokencontroller.new)!
        .link(() {
      return AppOperationController(managedContext);
    });
    currentRouter
        .route('log')
        .link(AppTokencontroller.new)!
        .link(() => AppLogController(managedContext));
    return currentRouter;
  }
}
