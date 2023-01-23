import 'dart:async';
import 'package:conduit_core/conduit_core.dart';   

class Migration2 extends Migration { 
  @override
  Future upgrade() async {
   		database.createTable(SchemaTable("_BankOperation", [SchemaColumn("id", ManagedPropertyType.bigInteger, isPrimaryKey: true, autoincrement: true, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("name", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: false),SchemaColumn("description", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: true, isNullable: false, isUnique: false),SchemaColumn("cathegory", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("date", ManagedPropertyType.datetime, isPrimaryKey: false, autoincrement: false, defaultValue: "now()", isIndexed: false, isNullable: false, isUnique: false),SchemaColumn("summ", ManagedPropertyType.doublePrecision, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: false, isUnique: false)]));
		database.addColumn("_BankOperation", SchemaColumn.relationship("owner", ManagedPropertyType.bigInteger, relatedTableName: "_User", relatedColumnName: "id", rule: DeleteRule.cascade, isNullable: false, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    