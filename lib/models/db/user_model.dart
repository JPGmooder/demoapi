import 'package:backend/models/db/logger_model.dart';
import 'package:conduit/conduit.dart';

class User extends ManagedObject<_User> implements _User {}

class _User {
  @primaryKey
  int? id;
  @Column(unique: true, indexed: true)
  String? userName;
  @Column(unique: true, indexed: true)
  String? email;
  @Serialize(input: true, output: false)
  String? password;
  @Column(nullable: true)
  String? accesTokent;
  @Column(nullable: true)
  String? refreshTokent;

  @Column(omitByDefault: true)
  String? salt;
  @Column(omitByDefault: true)
  String? hashedPassword;

  ManagedSet<BankOperation>? operations;

  ManagedSet<LoggerEntity>? logs;
}

class BankOperation extends ManagedObject<_BankOperation>
    implements _BankOperation {}

class _BankOperation {
  @primaryKey
  int? id;
  @Column()
  String? name;
  @Column()
  String? description;
  @Column()
  String? cathegory;
  @Column(defaultValue: "now()", indexed: true)
  DateTime? date;
  @Column(validators: [Validate.compare(greaterThan: 0.0)])
  double? summ;
  @Column(defaultValue: "true")
  bool? isVisible;
  @Relate(#operations, onDelete: DeleteRule.cascade, isRequired: true)
  User? owner;
}

