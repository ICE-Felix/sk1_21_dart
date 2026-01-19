/// Dart SDK for Datecs SK1-21 fiscal thermal printer.
///
/// Direct communication via DUDE COM object using PowerShell.
/// Automatically starts the COM server and connection to the printer.
///
/// Usage example:
/// ```dart
/// import 'package:datecs_sk1_21/datecs_sk1_21.dart';
///
/// void main() async {
///   final driver = DatecsDudeDriver();
///   await driver.startComServer();
///   await driver.openRs232Connection(Rs232Config(comPort: 4, baudRate: 115200));
///
///   // Simple fiscal receipt
///   await driver.openFiscalReceipt();
///   await driver.registerSale(SaleItem(name: 'Product', price: 10.0, quantity: 1, taxGroup: TaxGroup.b));
///   await driver.registerPayment(Payment(type: PaymentType.cash));
///   await driver.closeFiscalReceipt();
///   await driver.ejectPaper();
///
///   await driver.closeConnection();
///   driver.dispose();
/// }
/// ```
library datecs_sk1_21;

// Models
export 'src/models/models.dart';

// Driver abstract
export 'src/datecs_driver.dart';

// Driver implementation
export 'src/datecs_dude_driver.dart';
