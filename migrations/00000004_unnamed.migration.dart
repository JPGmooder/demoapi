import 'dart:async';
import 'package:conduit_core/conduit_core.dart';   

class Migration4 extends Migration { 
  @override
  Future upgrade() async {
   		database.createTable(SchemaTable("_Logger", [SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("operationDate", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: false),SchemaColumn("description", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false)]));
		database.addColumn("_Logger", SchemaColumn.relationship("owner", ManagedPropertyType.bigInteger, relatedTableName: "_User", relatedColumnName: "id", rule: DeleteRule.nullify, isNullable: true, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    