/// Main test file for datecs_sk1_21 package.
///
/// Run all tests with: dart test
library;

import 'driver_test.dart' as driver_test;
import 'models/config_test.dart' as config_test;
import 'models/department_test.dart' as department_test;
import 'models/error_codes_test.dart' as error_codes_test;
import 'models/fiscal_memory_test.dart' as fiscal_memory_test;
import 'models/journal_test.dart' as journal_test;
import 'models/plu_test.dart' as plu_test;
import 'models/receipt_test.dart' as receipt_test;
import 'models/reports_test.dart' as reports_test;
import 'models/status_test.dart' as status_test;

void main() {
  // Run all model tests
  config_test.main();
  receipt_test.main();
  status_test.main();
  error_codes_test.main();
  reports_test.main();
  plu_test.main();
  fiscal_memory_test.main();
  journal_test.main();
  department_test.main();

  // Run driver tests
  driver_test.main();
}
