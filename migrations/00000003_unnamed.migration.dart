import 'dart:async';
import 'package:conduit_core/conduit_core.dart';   

class Migration3 extends Migration { 
  @override
  Future upgrade() async {
   		database.alterColumn("_BankOperation", "name", (c) {c.isIndexed = false;});
		database.alterColumn("_BankOperation", "description", (c) {c.isIndexed = false;});
		database.alterColumn("_BankOperation", "date", (c) {c.isIndexed = true;});
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    