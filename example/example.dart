/// Interactive CLI example for Datecs SK1-21 fiscal printer.
///
/// Run with: dart run example/example.dart
import 'dart:io';
import 'package:datecs_sk1_21/datecs_sk1_21.dart';

late DatecsDudeDriver driver;
bool isConnected = false;

void main() async {
  print('');
  print('╔════════════════════════════════════════════════════════════╗');
  print('║         DATECS SK1-21 - Interactive CLI Example            ║');
  print('╚════════════════════════════════════════════════════════════╝');
  print('');

  driver = DatecsDudeDriver();

  // Listen to events for debugging (optional)
  driver.onError.listen((err) => print('  [ERROR] $err'));
  driver.onCommandSent.listen((cmd) => print('  [CMD] $cmd'));
  driver.onAnswerReceived.listen((ans) => print('  [RSP] $ans'));

  while (true) {
    printMainMenu();
    final choice = readLine('Select option');

    switch (choice) {
      case '1':
        await connectPrinter();
        break;
      case '2':
        await disconnectPrinter();
        break;
      case '3':
        await menuFiscalReceipt();
        break;
      case '4':
        await menuNonFiscalReceipt();
        break;
      case '5':
        await menuReports();
        break;
      case '6':
        await menuDisplay();
        break;
      case '7':
        await menuPaperOperations();
        break;
      case '8':
        await menuCashDrawer();
        break;
      case '9':
        await menuInformation();
        break;
      case '10':
        await menuDateTime();
        break;
      case '11':
        await menuVatRates();
        break;
      case '0':
        await cleanup();
        print('\nGoodbye!\n');
        exit(0);
      default:
        print('  Invalid option. Try again.\n');
    }
  }
}

void printMainMenu() {
  final status = isConnected ? '✓ Connected' : '✗ Not connected';
  print('');
  print('┌─────────────────────────────────────┐');
  print('│            MAIN MENU                │');
  print('│  Status: ${status.padRight(25)} │');
  print('├─────────────────────────────────────┤');
  print('│  1. Connect to printer              │');
  print('│  2. Disconnect                      │');
  print('├─────────────────────────────────────┤');
  print('│  3. Fiscal Receipt                  │');
  print('│  4. Non-Fiscal Receipt              │');
  print('│  5. Reports (X/Z)                   │');
  print('│  6. Display Control                 │');
  print('│  7. Paper Operations                │');
  print('│  8. Cash Drawer                     │');
  print('│  9. Information / Status            │');
  print('│ 10. Date / Time                     │');
  print('│ 11. VAT Rates                       │');
  print('├─────────────────────────────────────┤');
  print('│  0. Exit                            │');
  print('└─────────────────────────────────────┘');
}

// ============ CONNECTION ============

Future<void> connectPrinter() async {
  if (isConnected) {
    print('\n  Already connected.\n');
    return;
  }

  print('\n── Connect to Printer ──\n');
  print('  Connection type:');
  print('    1. RS232 (Serial/USB)');
  print('    2. TCP/IP (Network)');

  final connType = readLine('Select (1 or 2)', defaultValue: '1');

  try {
    await driver.startComServer();

    if (connType == '2') {
      // TCP/IP
      print('\n  TCP/IP Parameters:');
      final address = readLine('  IP Address', defaultValue: '192.168.1.100');
      final port = int.tryParse(
              readLine('  Port (default: 3999)', defaultValue: '3999')) ??
          3999;

      print('\n  Connecting to $address:$port...');
      await driver
          .openTcpIpConnection(TcpIpConfig(address: address, port: port));
    } else {
      // RS232
      print('\n  RS232 Parameters:');
      print('    COM Port: The serial port number (e.g., 4 for COM4)');
      print('    Baud Rate: Communication speed (SK1-21 default: 115200)');

      final comPort =
          int.tryParse(readLine('  COM Port', defaultValue: '4')) ?? 4;
      final baudRate =
          int.tryParse(readLine('  Baud Rate', defaultValue: '115200')) ??
              115200;

      print('\n  Connecting to COM$comPort at $baudRate baud...');
      await driver.openRs232Connection(
          Rs232Config(comPort: comPort, baudRate: baudRate));
    }

    isConnected = true;
    print('  ✓ Connected successfully!');

    if (driver.deviceInfo != null) {
      print('    Model: ${driver.deviceInfo!.model}');
      print('    Serial: ${driver.deviceInfo!.serialNumber}');
      print('    Firmware: ${driver.deviceInfo!.firmwareVersion}');
    }
  } catch (e) {
    print('  ✗ Connection failed: $e');
    isConnected = false;
  }
}

Future<void> disconnectPrinter() async {
  if (!isConnected) {
    print('\n  Not connected.\n');
    return;
  }

  print('\n  Disconnecting...');
  await driver.closeConnection();
  await driver.stopComServer();
  isConnected = false;
  print('  ✓ Disconnected.\n');
}

// ============ FISCAL RECEIPT ============

Future<void> menuFiscalReceipt() async {
  if (!checkConnection()) return;

  print('\n── Fiscal Receipt ──\n');
  print('  1. Print complete receipt (guided)');
  print('  2. Open receipt');
  print('  3. Add sale item');
  print('  4. Print subtotal');
  print('  5. Register payment');
  print('  6. Close receipt');
  print('  7. Cancel receipt');
  print('  8. Print fiscal text');
  print('  0. Back');

  final choice = readLine('Select option');

  switch (choice) {
    case '1':
      await printGuidedFiscalReceipt();
      break;
    case '2':
      await openFiscalReceipt();
      break;
    case '3':
      await addSaleItem();
      break;
    case '4':
      await printSubtotal();
      break;
    case '5':
      await registerPayment();
      break;
    case '6':
      await closeFiscalReceipt();
      break;
    case '7':
      await cancelFiscalReceipt();
      break;
    case '8':
      await printFiscalText();
      break;
  }
}

Future<void> printGuidedFiscalReceipt() async {
  print('\n── Guided Fiscal Receipt ──\n');

  // Open receipt
  print('  Opening fiscal receipt...');
  var response = await driver.openFiscalReceipt();
  if (response.hasError) {
    print('  ✗ Error code: ${response.errorCode}');
    print('  ✗ Error type: ${response.error.name}');
    print('  ✗ Error: ${response.errorDescription}');
    if (response.deviceAnswer.isNotEmpty) {
      print('  ✗ Device response: ${response.deviceAnswer}');
    }
    return;
  }
  print('  ✓ Receipt opened\n');

  // Add items
  print('  Add items (enter empty name to finish):');
  while (true) {
    print('');
    final name = readLine('  Product name (empty to finish)');
    if (name.isEmpty) break;

    final price =
        double.tryParse(readLine('  Price', defaultValue: '10.00')) ?? 10.0;
    final qty =
        double.tryParse(readLine('  Quantity', defaultValue: '1')) ?? 1.0;

    print('  Tax groups: A=0%, B=19%, C=9%, D=5%');
    final taxStr =
        readLine('  Tax group (A/B/C/D)', defaultValue: 'B').toUpperCase();
    final taxGroup = _parseTaxGroup(taxStr);

    final item =
        SaleItem(name: name, price: price, quantity: qty, taxGroup: taxGroup);
    response = await driver.registerSale(item);

    if (response.hasError) {
      print('  ✗ Error: ${response.errorDescription}');
    } else {
      print('  ✓ Added: $name x $qty @ $price (Tax ${taxStr})');
    }
  }

  // Payment
  print('\n  Payment types: 0=Cash, 1=Card, 2=Credit');
  final payType =
      int.tryParse(readLine('  Payment type', defaultValue: '0')) ?? 0;
  final paymentType =
      PaymentType.values[payType.clamp(0, PaymentType.values.length - 1)];

  response = await driver.registerPayment(Payment(type: paymentType));
  if (response.hasError) {
    print('  ✗ Payment error: ${response.errorDescription}');
    await driver.cancelFiscalReceipt();
    return;
  }
  print('  ✓ Payment registered: ${paymentType.name}');

  // Close
  response = await driver.closeFiscalReceipt();
  if (response.hasError) {
    print('  ✗ Close error: ${response.errorDescription}');
    return;
  }
  print('  ✓ Receipt closed');

  // Eject
  await driver.ejectPaper();
  print('  ✓ Paper ejected\n');
}

Future<void> openFiscalReceipt() async {
  print('\n── Open Fiscal Receipt ──\n');
  print('  Receipt types: 1=Fiscal, 2=Invoice, 3=Airport');
  final typeCode =
      int.tryParse(readLine('  Receipt type', defaultValue: '1')) ?? 1;
  final type = ReceiptType.values
      .firstWhere((t) => t.code == typeCode, orElse: () => ReceiptType.fiscal);

  print('  Operator code: Identifies the cashier (1-30)');
  final opCode = readLine('  Operator code', defaultValue: '1');

  print('  Operator password: 4-digit password');
  final opPassword = readLine('  Operator password', defaultValue: '0001');

  final response = await driver.openFiscalReceipt(
    type: type,
    operator: OperatorInfo(code: opCode, password: opPassword),
  );

  printResponse('Open Fiscal Receipt', response);
}

Future<void> addSaleItem() async {
  print('\n── Add Sale Item ──\n');

  print('  Product name: Text to print on receipt (max 36 chars)');
  final name = readLine('  Name', defaultValue: 'Product');

  print('  Price: Unit price with up to 2 decimals');
  final price =
      double.tryParse(readLine('  Price', defaultValue: '10.00')) ?? 10.0;

  print('  Quantity: Amount sold (decimals allowed for weight items)');
  final qty = double.tryParse(readLine('  Quantity', defaultValue: '1')) ?? 1.0;

  print('  Tax group: A=0%, B=19%, C=9%, D=5%, E-H=custom');
  final taxStr = readLine('  Tax group (A-H)', defaultValue: 'B').toUpperCase();
  final taxGroup = _parseTaxGroup(taxStr);

  print(
      '  Discount type: 0=None, 1=Surcharge%, 2=Discount%, 3=Surcharge value, 4=Discount value');
  final discType =
      int.tryParse(readLine('  Discount type', defaultValue: '0')) ?? 0;
  final discountType =
      DiscountType.values[discType.clamp(0, DiscountType.values.length - 1)];

  double discountValue = 0;
  if (discType > 0) {
    print('  Discount value: Percentage or absolute value');
    discountValue =
        double.tryParse(readLine('  Discount value', defaultValue: '0')) ?? 0;
  }

  final item = SaleItem(
    name: name,
    price: price,
    quantity: qty,
    taxGroup: taxGroup,
    discountType: discountType,
    discountValue: discountValue,
  );

  final response = await driver.registerSale(item);
  printResponse('Register Sale', response);
  print('  Total for item: ${item.total.toStringAsFixed(2)}');
}

Future<void> printSubtotal() async {
  print('\n── Subtotal ──\n');

  print('  Print subtotal: Show subtotal line on receipt');
  final printSub =
      readLine('  Print subtotal? (y/n)', defaultValue: 'y').toLowerCase() ==
          'y';

  print('  Display subtotal: Show on customer display');
  final displaySub =
      readLine('  Display subtotal? (y/n)', defaultValue: 'y').toLowerCase() ==
          'y';

  final response =
      await driver.subtotal(printText: printSub, displayText: displaySub);
  printResponse('Subtotal', response);
}

Future<void> registerPayment() async {
  print('\n── Register Payment ──\n');

  print('  Payment types:');
  print('    0 = Cash');
  print('    1 = Card');
  print('    2 = Credit');
  print('    3 = Meal tickets');
  print('    4 = Value tickets');
  print('    5 = Voucher');
  print('    6 = Modern payment (Apple/Google Pay)');
  print('    7 = Card with cash advance');
  print('    8 = Other');
  print('    9 = Currency');

  final payType =
      int.tryParse(readLine('  Payment type', defaultValue: '0')) ?? 0;
  final paymentType =
      PaymentType.values[payType.clamp(0, PaymentType.values.length - 1)];

  print('  Amount: Payment amount (0 or empty = exact amount due)');
  final amountStr = readLine('  Amount', defaultValue: '0');
  final amount = double.tryParse(amountStr);

  final payment =
      Payment(type: paymentType, amount: amount == 0 ? null : amount);
  final response = await driver.registerPayment(payment);
  printResponse('Register Payment', response);
}

Future<void> closeFiscalReceipt() async {
  print('\n  Closing fiscal receipt...');
  final response = await driver.closeFiscalReceipt();
  printResponse('Close Fiscal Receipt', response);
}

Future<void> cancelFiscalReceipt() async {
  print('\n  Canceling fiscal receipt...');
  final response = await driver.cancelFiscalReceipt();
  printResponse('Cancel Fiscal Receipt', response);
}

Future<void> printFiscalText() async {
  print('\n── Print Fiscal Text ──\n');
  print('  Text to print within fiscal receipt (max 36 chars)');
  final text = readLine('  Text');

  final response = await driver.printFiscalText(text);
  printResponse('Print Fiscal Text', response);
}

// ============ NON-FISCAL RECEIPT ============

Future<void> menuNonFiscalReceipt() async {
  if (!checkConnection()) return;

  print('\n── Non-Fiscal Receipt ──\n');
  print('  1. Print complete receipt (guided)');
  print('  2. Open receipt');
  print('  3. Print text line');
  print('  4. Close receipt');
  print('  0. Back');

  final choice = readLine('Select option');

  switch (choice) {
    case '1':
      await printGuidedNonFiscalReceipt();
      break;
    case '2':
      await openNonFiscalReceipt();
      break;
    case '3':
      await printNonFiscalText();
      break;
    case '4':
      await closeNonFiscalReceipt();
      break;
  }
}

Future<void> printGuidedNonFiscalReceipt() async {
  print('\n── Guided Non-Fiscal Receipt ──\n');

  var response = await driver.openNonFiscalReceipt();
  if (response.hasError) {
    print('  ✗ Error: ${response.errorDescription}');
    return;
  }
  print('  ✓ Receipt opened\n');

  print('  Enter text lines (empty line to finish):');
  while (true) {
    final text = readLine('  ');
    if (text.isEmpty) break;

    response = await driver.printNonFiscalText(text);
    if (response.hasError) {
      print('  ✗ Error: ${response.errorDescription}');
    }
  }

  response = await driver.closeNonFiscalReceipt();
  print('  ✓ Receipt closed');

  await driver.ejectPaper();
  print('  ✓ Paper ejected\n');
}

Future<void> openNonFiscalReceipt() async {
  print('\n  Opening non-fiscal receipt...');
  final response = await driver.openNonFiscalReceipt();
  printResponse('Open Non-Fiscal Receipt', response);
}

Future<void> printNonFiscalText() async {
  print('\n── Print Non-Fiscal Text ──\n');
  print('  Text to print (max 42 chars per line)');
  final text = readLine('  Text');

  final response = await driver.printNonFiscalText(text);
  printResponse('Print Non-Fiscal Text', response);
}

Future<void> closeNonFiscalReceipt() async {
  print('\n  Closing non-fiscal receipt...');
  final response = await driver.closeNonFiscalReceipt();
  printResponse('Close Non-Fiscal Receipt', response);
}

// ============ REPORTS ============

Future<void> menuReports() async {
  if (!checkConnection()) return;

  print('\n── Reports ──\n');
  print('  1. X Report (preview, no reset)');
  print('  2. Z Report (daily closure, resets counters)');
  print('  3. Print diagnostic');
  print('  4. Operators report');
  print('  5. Departments report');
  print('  0. Back');

  final choice = readLine('Select option');

  switch (choice) {
    case '1':
      print('\n  Generating X Report...');
      print('  (This is a preview report - counters are NOT reset)');
      final response =
          await driver.generateDailyReport(DailyReportType.xReport);
      printResponse('X Report', response);
      await driver.ejectPaper();
      break;
    case '2':
      print('\n  ⚠️  WARNING: Z Report will reset daily counters!');
      print('  This can only be done ONCE per day.');
      final confirm = readLine('  Are you sure? (yes/no)', defaultValue: 'no');
      if (confirm.toLowerCase() == 'yes') {
        print('\n  Generating Z Report...');
        final response =
            await driver.generateDailyReport(DailyReportType.zReport);
        printResponse('Z Report', response);
        await driver.ejectPaper();
      } else {
        print('  Canceled.');
      }
      break;
    case '3':
      print('\n  Printing diagnostic...');
      final response = await driver.printDiagnostic();
      printResponse('Print Diagnostic', response);
      await driver.ejectPaper();
      break;
    case '4':
      print('\n  Printing operators report...');
      final response = await driver.printOperatorsReport();
      printResponse('Operators Report', response);
      await driver.ejectPaper();
      break;
    case '5':
      print('\n  Printing departments report...');
      final response = await driver.printDepartmentsReport();
      printResponse('Departments Report', response);
      await driver.ejectPaper();
      break;
  }
}

// ============ DISPLAY ============

Future<void> menuDisplay() async {
  if (!checkConnection()) return;

  print('\n── Display Control ──\n');
  print('  The SK1-21 has a 2-line customer display.');
  print('');
  print('  1. Clear display');
  print('  2. Set upper line');
  print('  3. Set lower line');
  print('  4. Set both lines');
  print('  0. Back');

  final choice = readLine('Select option');

  switch (choice) {
    case '1':
      print('\n  Clearing display...');
      final response = await driver.clearDisplay();
      printResponse('Clear Display', response);
      break;
    case '2':
      print('\n  Upper line text (max 20 chars):');
      final text = readLine('  Text');
      final response = await driver.displayUpperLine(text);
      printResponse('Display Upper Line', response);
      break;
    case '3':
      print('\n  Lower line text (max 20 chars):');
      final text = readLine('  Text');
      final response = await driver.displayLowerLine(text);
      printResponse('Display Lower Line', response);
      break;
    case '4':
      print('\n  Upper line text (max 20 chars):');
      final upper = readLine('  Upper');
      print('  Lower line text (max 20 chars):');
      final lower = readLine('  Lower');
      await driver.clearDisplay();
      await driver.displayUpperLine(upper);
      final response = await driver.displayLowerLine(lower);
      printResponse('Display Both Lines', response);
      break;
  }
}

// ============ PAPER OPERATIONS ============

Future<void> menuPaperOperations() async {
  if (!checkConnection()) return;

  print('\n── Paper Operations ──\n');
  print('  1. Feed paper');
  print('  2. Cut paper');
  print('  3. Eject paper (feed + cut)');
  print('  0. Back');

  final choice = readLine('Select option');

  switch (choice) {
    case '1':
      print('\n  Lines to feed: Number of lines (1-99)');
      final lines = int.tryParse(readLine('  Lines', defaultValue: '5')) ?? 5;
      final response = await driver.paperFeed(lines.clamp(1, 99));
      printResponse('Paper Feed', response);
      break;
    case '2':
      print('\n  Cutting paper...');
      final response = await driver.paperCut();
      printResponse('Paper Cut', response);
      break;
    case '3':
      print('\n  Feed lines before cut: Number of lines (1-99)');
      print('  Note: SK1-21 does NOT have software paper presenter.');
      print('        Use physical button to eject paper after cut.');
      final lines = int.tryParse(readLine('  Lines', defaultValue: '5')) ?? 5;
      final response = await driver.ejectPaper(lines.clamp(1, 99));
      printResponse('Eject Paper', response);
      break;
  }
}

// ============ CASH DRAWER ============

Future<void> menuCashDrawer() async {
  if (!checkConnection()) return;

  print('\n── Cash Drawer ──\n');
  print('  1. Open cash drawer');
  print('  2. Cash in (add money)');
  print('  3. Cash out (remove money)');
  print('  0. Back');

  final choice = readLine('Select option');

  switch (choice) {
    case '1':
      print('\n  Opening cash drawer...');
      final response = await driver.openCashDrawer();
      printResponse('Open Cash Drawer', response);
      break;
    case '2':
      print('\n  Cash In: Register money added to drawer');
      print('  Amount: Positive value to add');
      final amount =
          double.tryParse(readLine('  Amount', defaultValue: '100')) ?? 100;
      final response = await driver.cashInOut(amount.abs());
      printResponse('Cash In', response);
      break;
    case '3':
      print('\n  Cash Out: Register money removed from drawer');
      print('  Amount: Value to remove (will be negative)');
      final amount =
          double.tryParse(readLine('  Amount', defaultValue: '50')) ?? 50;
      final response = await driver.cashInOut(-amount.abs());
      printResponse('Cash Out', response);
      break;
  }
}

// ============ INFORMATION ============

Future<void> menuInformation() async {
  if (!checkConnection()) return;

  print('\n── Information / Status ──\n');
  print('  1. Printer status');
  print('  2. Diagnostic info');
  print('  3. Receipt status');
  print('  4. Current receipt info');
  print('  5. Daily taxation info');
  print('  6. Remaining Z reports');
  print('  7. Read last error');
  print('  8. Check connection');
  print('  0. Back');

  final choice = readLine('Select option');

  switch (choice) {
    case '1':
      print('\n  Reading printer status...');
      final status = await driver.getStatus();
      print('\n  Printer Status:');
      print('    Fiscal receipt open: ${status.fiscalReceiptOpen}');
      print('    Non-fiscal receipt open: ${status.nonFiscalReceiptOpen}');
      print('    Paper near end: ${status.paperNearEnd}');
      print('    Paper out: ${status.paperOut}');
      print('    Fiscal memory full: ${status.fiscalMemoryFull}');
      print('    Fiscal memory near full: ${status.fiscalMemoryNearFull}');
      print('    Fiscalized: ${status.fiscalized}');
      print('    Has error: ${status.hasError}');
      print('    Is ready: ${status.isReady}');
      break;
    case '2':
      print('\n  Reading diagnostic info...');
      final info = await driver.getDiagnosticInfo();
      print('\n  Diagnostic Info:');
      print('    Model: ${info.model}');
      print('    Serial: ${info.serialNumber}');
      print('    Firmware: ${info.firmwareVersion}');
      print('    Fiscal memory serial: ${info.fiscalMemorySerial}');
      print('    Total RAM: ${info.totalRam}');
      print('    Free RAM: ${info.freeRam}');
      break;
    case '3':
      print('\n  Reading receipt status...');
      final status = await driver.getReceiptStatus();
      print('\n  Receipt Status:');
      print('    Receipt open: ${status.isOpen}');
      print('    Fiscal receipt: ${status.isFiscal}');
      print('    Sales count: ${status.salesCount}');
      print('    Subtotal: ${status.subtotal}');
      print('    Receipt number: ${status.receiptNumber}');
      break;
    case '4':
      print('\n  Reading current receipt info...');
      final info = await driver.getCurrentReceiptInfo();
      print('\n  Current Receipt Info:');
      print('    Receipt open: ${info.isOpen}');
      print('    Sales count: ${info.salesCount}');
      print('    Subtotal net: ${info.subtotalNet}');
      print('    Total VAT: ${info.totalVat}');
      print('    Total gross: ${info.totalGross}');
      print('    Receipt number: ${info.receiptNumber}');
      print('    Unique sale number: ${info.uniqueSaleNumber}');
      break;
    case '5':
      print('\n  Reading daily taxation info...');
      final info = await driver.getDailyTaxationInfo();
      print('\n  Daily Taxation:');
      print('    Grand total: ${info.grandTotal}');
      print('    Grand total VAT: ${info.grandTotalVat}');
      print('    Fiscal receipts count: ${info.fiscalReceiptsCount}');
      print('    Cancelled receipts: ${info.cancelledReceiptsCount}');
      print('    Sales by tax group:');
      for (final entry in info.salesByTaxGroup.entries) {
        print('      ${entry.key.name.toUpperCase()}: ${entry.value}');
      }
      break;
    case '6':
      print('\n  Reading remaining Z reports...');
      final remaining = await driver.getRemainingZReports();
      print('\n  Remaining Z Reports: $remaining');
      print('  (Fiscal memory can store max 2500 Z reports)');
      break;
    case '7':
      print('\n  Reading last error...');
      final error = await driver.readLastError();
      print('\n  Last Error: $error');
      break;
    case '8':
      print('\n  Checking connection...');
      final response = await driver.checkConnection();
      printResponse('Check Connection', response);
      break;
  }
}

// ============ DATE/TIME ============

Future<void> menuDateTime() async {
  if (!checkConnection()) return;

  print('\n── Date / Time ──\n');
  print('  1. Read current date/time');
  print('  2. Set date/time');
  print('  0. Back');

  final choice = readLine('Select option');

  switch (choice) {
    case '1':
      print('\n  Reading date/time...');
      final dt = await driver.readDateTime();
      if (dt != null) {
        print(
            '  Current: ${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}');
      } else {
        print('  ✗ Could not read date/time');
      }
      break;
    case '2':
      print('\n  Set Date/Time:');
      print('  ⚠️  Can only be set once between Z reports!');
      print('');
      final now = DateTime.now();
      final day =
          int.tryParse(readLine('  Day (1-31)', defaultValue: '${now.day}')) ??
              now.day;
      final month = int.tryParse(
              readLine('  Month (1-12)', defaultValue: '${now.month}')) ??
          now.month;
      final year =
          int.tryParse(readLine('  Year', defaultValue: '${now.year}')) ??
              now.year;
      final hour = int.tryParse(
              readLine('  Hour (0-23)', defaultValue: '${now.hour}')) ??
          now.hour;
      final minute = int.tryParse(
              readLine('  Minute (0-59)', defaultValue: '${now.minute}')) ??
          now.minute;

      final dt = DateTime(year, month, day, hour, minute);
      final response = await driver.setDateTime(dt);
      printResponse('Set Date/Time', response);
      break;
  }
}

// ============ VAT RATES ============

Future<void> menuVatRates() async {
  if (!checkConnection()) return;

  print('\n── VAT Rates ──\n');
  print('  1. Read current VAT rates');
  print('  2. Program VAT rates');
  print('  0. Back');

  final choice = readLine('Select option');

  switch (choice) {
    case '1':
      print('\n  Reading VAT rates...');
      final rates = await driver.readVatRates();
      print('\n  Current VAT Rates:');
      for (final entry in rates.entries) {
        print('    Group ${entry.key.name.toUpperCase()}: ${entry.value}%');
      }
      break;
    case '2':
      print('\n  Program VAT Rates:');
      print('  ⚠️  Can only be changed after Z report!');
      print('');
      final rateA = double.tryParse(
              readLine('  Rate A (default 0%)', defaultValue: '0')) ??
          0;
      final rateB = double.tryParse(
              readLine('  Rate B (default 19%)', defaultValue: '19')) ??
          19;
      final rateC = double.tryParse(
              readLine('  Rate C (default 9%)', defaultValue: '9')) ??
          9;
      final rateD = double.tryParse(
              readLine('  Rate D (default 5%)', defaultValue: '5')) ??
          5;

      final rates = {
        TaxGroup.a: rateA,
        TaxGroup.b: rateB,
        TaxGroup.c: rateC,
        TaxGroup.d: rateD,
      };

      final response = await driver.programVatRates(rates);
      printResponse('Program VAT Rates', response);
      break;
  }
}

// ============ HELPERS ============

String readLine(String prompt, {String defaultValue = ''}) {
  final defaultHint = defaultValue.isNotEmpty ? ' [$defaultValue]' : '';
  stdout.write('$prompt$defaultHint: ');
  final input = stdin.readLineSync() ?? '';
  return input.isEmpty ? defaultValue : input;
}

bool checkConnection() {
  if (!isConnected) {
    print('\n  ✗ Not connected. Please connect first.\n');
    return false;
  }
  return true;
}

void printResponse(String operation, DatecsResponse response) {
  print('');
  print('  ┌─ $operation ─');
  print('  │ Success: ${!response.hasError}');
  if (response.hasError) {
    print('  │ Error code: ${response.errorCode}');
    print('  │ Error type: ${response.error.name}');
    print('  │ Error: ${response.errorDescription}');
  }
  if (response.deviceAnswer.isNotEmpty) {
    print('  │ Response: ${response.deviceAnswer}');
  }
  print('  └────────────────────');
}

TaxGroup _parseTaxGroup(String s) {
  switch (s.toUpperCase()) {
    case 'A':
      return TaxGroup.a;
    case 'C':
      return TaxGroup.c;
    case 'D':
      return TaxGroup.d;
    case 'E':
      return TaxGroup.e;
    case 'F':
      return TaxGroup.f;
    case 'G':
      return TaxGroup.g;
    case 'H':
      return TaxGroup.h;
    default:
      return TaxGroup.b;
  }
}

Future<void> cleanup() async {
  if (isConnected) {
    await driver.closeConnection();
    await driver.stopComServer();
  }
  driver.dispose();
}
