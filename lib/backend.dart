import 'dart:io';

import 'package:backend/app_service.dart';
import 'package:conduit/conduit.dart';

void main(List<String> arguments) async {
  final port = int.parse(Platform.environment['PORT'] ?? "6969");
  final service = Application<AppService>()..options.port = port;
  await service.start(consoleLogging: true, numberOfInstances: 3);
}
