import 'package:backend/models/db/user_model.dart';
import 'package:conduit/conduit.dart';

class LoggerEntity extends ManagedObject<_Logger> implements _Logger {}

class _Logger {
  @primaryKey
  int? id;
  @Column(indexed: true)
  DateTime? operationDate;
  @Column(nullable: false)
  String? description;
  
  @Relate(#logs)
  User? owner;
}
