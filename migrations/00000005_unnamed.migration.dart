import 'dart:async';
import 'package:conduit_core/conduit_core.dart';

class Migration5 extends Migration {
  @override
  Future upgrade() async {
    database.addColumn(
        "_BankOperation",
        SchemaColumn("isVisible", ManagedPropertyType.boolean,
            isPrimaryKey: false,
            autoincrement: false,
            defaultValue: "true",
            isIndexed: false,
            isNullable: false,
            isUnique: false));
  }

  @override
  Future downgrade() async {}

  @override
  Future seed() async {}
}
