import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'datecs_driver.dart';
import 'models/models.dart';

/// DatecsDriver implementation using DUDE COM directly via PowerShell.
///
/// This implementation maintains a persistent connection to the printer
/// through a PowerShell process that loads the DUDE COM driver.
///
/// Example:
/// ```dart
/// final driver = DatecsDudeDriver();
/// await driver.startComServer();
/// await driver.openRs232Connection(Rs232Config(comPort: 4, baudRate: 115200));
///
/// // Fiscal receipt
/// await driver.openFiscalReceipt();
/// await driver.registerSale(SaleItem(name: 'Product', price: 10.0));
/// await driver.registerPayment(Payment(type: PaymentType.cash));
/// await driver.closeFiscalReceipt();
///
/// await driver.closeConnection();
/// await driver.stopComServer();
/// driver.dispose();
/// ```
class DatecsDudeDriver extends DatecsDriver {
  Process? _process;
  StreamSubscription<String>? _stdoutSubscription;

  // Response queue - solves the broadcast streams problem
  final Queue<String> _responseQueue = Queue<String>();
  Completer<String>? _responseCompleter;

  bool _isServerStarted = false;
  bool _isConnected = false;
  DeviceInfo? _deviceInfo;

  final _onError = StreamController<String>.broadcast();
  final _onStatusChange = StreamController<int>.broadcast();
  final _onCommandSent = StreamController<String>.broadcast();
  final _onAnswerReceived = StreamController<String>.broadcast();

  // ============ State ============

  @override
  bool get isServerStarted => _isServerStarted;

  @override
  bool get isConnected => _isConnected;

  @override
  DeviceInfo? get deviceInfo => _deviceInfo;

  // ============ Events ============

  @override
  Stream<String> get onError => _onError.stream;

  @override
  Stream<int> get onStatusChange => _onStatusChange.stream;

  @override
  Stream<String> get onCommandSent => _onCommandSent.stream;

  @override
  Stream<String> get onAnswerReceived => _onAnswerReceived.stream;

  // ============ Lifecycle ============

  @override
  Future<void> startComServer() async {
    if (_isServerStarted) {
      return;
    }
    _isServerStarted = true;
  }

  @override
  Future<void> openRs232Connection(Rs232Config config) async {
    if (!_isServerStarted) {
      throw StateError('COM Server not started. Call startComServer() first.');
    }

    if (_isConnected) {
      return;
    }

    final portNum = config.comPort;
    final baudRate = config.baudRate;

    final script = '''
\$ErrorActionPreference = "Stop"

try {
  \$dude = New-Object -ComObject "dude.CFD_DUDE"
} catch {
  Write-Output "ERROR|DUDE_NOT_FOUND|Could not create DUDE COM object"
  exit 1
}

\$dude.set_TransportType(1) | Out-Null
\$dude.set_RS232($portNum, $baudRate) | Out-Null
\$errorCode = \$dude.open_Connection()

if (\$errorCode -ne 0) {
  Write-Output "ERROR|CONNECTION_FAILED|\$errorCode"
  exit 1
}

Write-Output "CONNECTED"

while (\$true) {
  \$line = Read-Host
  if (\$line -eq "EXIT") { break }
  if (\$line -eq "") { continue }

  \$parts = \$line.Split("|", 2)
  if (\$parts.Length -eq 0 -or \$parts[0] -eq "") { continue }

  \$command = [int]\$parts[0]
  \$data = if (\$parts.Length -gt 1) { \$parts[1] } else { "" }

  \$outputText = ""
  try {
    \$ec = \$dude.execute_Command(\$command, \$data, [ref]\$outputText)
    Write-Output "RESULT|\$ec|\$outputText"
  } catch {
    Write-Output "RESULT|-1|Exception: \$_"
  }
}

\$dude.close_Connection() | Out-Null
Write-Output "DISCONNECTED"
''';

    try {
      _process = await Process.start(
        'powershell',
        ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', script],
        mode: ProcessStartMode.normal,
      );

      // Listen to stderr for debugging
      _process!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => _onError.add('PS_STDERR: $line'));

      // Listen to stdout and add to queue
      _stdoutSubscription = _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(_handleLine);

      // Wait for first response
      final firstLine =
          await _waitForResponse(timeout: const Duration(seconds: 15));

      if (firstLine == 'CONNECTED') {
        _isConnected = true;
        await _readDeviceInfo();
      } else if (firstLine.startsWith('ERROR|')) {
        final parts = firstLine.split('|');
        final errorType = parts.length > 1 ? parts[1] : 'UNKNOWN';
        final errorMsg = parts.length > 2 ? parts[2] : '';
        await _cleanup();
        throw StateError('Failed to connect: $errorType - $errorMsg');
      } else {
        await _cleanup();
        throw StateError('Unexpected response: $firstLine');
      }
    } catch (e) {
      await _cleanup();
      _onError.add('Failed to start connection: $e');
      rethrow;
    }
  }

  @override
  Future<void> openTcpIpConnection(TcpIpConfig config) async {
    if (!_isServerStarted) {
      throw StateError('COM Server not started. Call startComServer() first.');
    }

    final script = '''
\$ErrorActionPreference = "Stop"

try {
  \$dude = New-Object -ComObject "dude.CFD_DUDE"
} catch {
  Write-Output "ERROR|DUDE_NOT_FOUND|Could not create DUDE COM object"
  exit 1
}

\$dude.set_TransportType(2) | Out-Null
\$dude.set_TCPIP("${config.address}", ${config.port}) | Out-Null
\$errorCode = \$dude.open_Connection()

if (\$errorCode -ne 0) {
  Write-Output "ERROR|CONNECTION_FAILED|\$errorCode"
  exit 1
}

Write-Output "CONNECTED"

while (\$true) {
  \$line = Read-Host
  if (\$line -eq "EXIT") { break }
  if (\$line -eq "") { continue }

  \$parts = \$line.Split("|", 2)
  if (\$parts.Length -eq 0 -or \$parts[0] -eq "") { continue }

  \$command = [int]\$parts[0]
  \$data = if (\$parts.Length -gt 1) { \$parts[1] } else { "" }

  \$outputText = ""
  try {
    \$ec = \$dude.execute_Command(\$command, \$data, [ref]\$outputText)
    Write-Output "RESULT|\$ec|\$outputText"
  } catch {
    Write-Output "RESULT|-1|Exception: \$_"
  }
}

\$dude.close_Connection() | Out-Null
Write-Output "DISCONNECTED"
''';

    try {
      _process = await Process.start(
        'powershell',
        ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', script],
        mode: ProcessStartMode.normal,
      );

      // Listen to stderr for debugging
      _process!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) => _onError.add('PS_STDERR: $line'));

      _stdoutSubscription = _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(_handleLine);

      final firstLine =
          await _waitForResponse(timeout: const Duration(seconds: 15));

      if (firstLine == 'CONNECTED') {
        _isConnected = true;
        await _readDeviceInfo();
      } else if (firstLine.startsWith('ERROR|')) {
        final parts = firstLine.split('|');
        final errorType = parts.length > 1 ? parts[1] : 'UNKNOWN';
        final errorMsg = parts.length > 2 ? parts[2] : '';
        await _cleanup();
        throw StateError('Failed to connect: $errorType - $errorMsg');
      } else {
        await _cleanup();
        throw StateError('Unexpected response: $firstLine');
      }
    } catch (e) {
      await _cleanup();
      _onError.add('Failed to start connection: $e');
      rethrow;
    }
  }

  /// Handler for output lines
  void _handleLine(String line) {
    // Ignore lines that are not valid responses (Read-Host echoes input)
    if (!line.startsWith('RESULT|') &&
        !line.startsWith('CONNECTED') &&
        !line.startsWith('DISCONNECTED') &&
        !line.startsWith('ERROR|')) {
      return;
    }

    // If we have a completer waiting, complete it directly
    if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
      _responseCompleter!.complete(line);
      _responseCompleter = null;
    } else {
      // Otherwise, add to queue
      _responseQueue.add(line);
    }
  }

  /// Wait for a response with timeout
  Future<String> _waitForResponse(
      {Duration timeout = const Duration(seconds: 30)}) async {
    // If we already have something in queue, return it
    if (_responseQueue.isNotEmpty) {
      return _responseQueue.removeFirst();
    }

    // Otherwise, wait
    _responseCompleter = Completer<String>();
    return _responseCompleter!.future.timeout(timeout);
  }

  @override
  Future<void> closeConnection() async {
    if (!_isConnected) return;
    await _cleanup();
  }

  @override
  Future<void> stopComServer() async {
    await closeConnection();
    _isServerStarted = false;
  }

  @override
  void dispose() {
    _cleanup();
    _onError.close();
    _onStatusChange.close();
    _onCommandSent.close();
    _onAnswerReceived.close();
  }

  Future<void> _cleanup() async {
    try {
      if (_process != null) {
        _process!.stdin.writeln('EXIT');
        await _process!.stdin.flush();
        await _process!.exitCode.timeout(const Duration(seconds: 5));
      }
    } catch (_) {
      _process?.kill();
    }

    await _stdoutSubscription?.cancel();
    _responseQueue.clear();
    _responseCompleter = null;

    _stdoutSubscription = null;
    _process = null;
    _isConnected = false;
    _deviceInfo = null;
  }

  Future<void> _readDeviceInfo() async {
    final response = await executeCommand(90);
    if (!response.hasError && response.deviceAnswer.isNotEmpty) {
      // Parse: SK1-21,417320 02Nov20 1000,FFFF,00000000,DB4020000539
      final parts = response.deviceAnswer.split(',');
      _deviceInfo = DeviceInfo(
        model: parts.isNotEmpty ? parts[0] : 'Unknown',
        serialNumber: parts.length > 4 ? parts[4] : '',
        firmwareVersion: parts.length > 1 ? parts[1] : '',
        codePage: '1251',
        distributor: 'Datecs',
        isFiscalPrinter: true,
      );
    }
  }

  // ============ Raw Commands ============

  @override
  Future<DatecsResponse> executeCommand(int command, [String data = '']) async {
    if (!_isConnected || _process == null) {
      throw StateError('Not connected. Call openRs232Connection() first.');
    }

    _onCommandSent.add('CMD $command: $data');

    // Send command
    final commandLine = '$command|$data';
    _process!.stdin.writeln(commandLine);
    await _process!.stdin.flush();

    // Read response
    try {
      final response =
          await _waitForResponse(timeout: const Duration(seconds: 30));

      if (response.startsWith('RESULT|')) {
        final parts = response.substring('RESULT|'.length).split('|');
        final errorCode = int.tryParse(parts[0]) ?? -1;
        final deviceAnswer = parts.length > 1 ? parts.sublist(1).join('|') : '';

        _onAnswerReceived.add('RSP $errorCode: $deviceAnswer');

        if (errorCode != 0) {
          _onError.add('Command $command error: $errorCode');
        }

        return DatecsResponse(
          errorCode: errorCode,
          deviceAnswer: deviceAnswer,
          success: true,
        );
      }

      throw StateError('Invalid response: $response');
    } catch (e) {
      _onError.add('Command timeout or error: $e');
      return DatecsResponse(
        errorCode: -1,
        deviceAnswer: 'Error: $e',
        success: false,
      );
    }
  }

  // ============ Basic Commands ============

  @override
  Future<DiagnosticInfo> getDiagnosticInfo() async {
    final response = await executeCommand(90);
    return DiagnosticInfo.fromResponse(response.deviceAnswer);
  }

  @override
  Future<PrinterStatus> getStatus() async {
    final response = await executeCommand(74);
    // Response contains status bytes as hex or numbers
    if (response.hasError || response.deviceAnswer.isEmpty) {
      return const PrinterStatus();
    }
    // Parse status bytes from response
    final parts = response.deviceAnswer.split('\t');
    final bytes = <int>[];
    for (final part in parts) {
      final value = int.tryParse(part);
      if (value != null) {
        bytes.add(value);
      }
    }
    return PrinterStatus.fromBytes(bytes);
  }

  @override
  Future<DatecsResponse> checkConnection() => executeCommand(45);

  @override
  Future<DatecsResponse> printDiagnostic() => executeCommand(71);

  // ============ Display ============

  @override
  Future<DatecsResponse> clearDisplay() => executeCommand(33);

  @override
  Future<DatecsResponse> displayUpperLine(String text) =>
      executeCommand(47, '$text\t');

  @override
  Future<DatecsResponse> displayLowerLine(String text) =>
      executeCommand(35, '$text\t');

  // ============ Fiscal Receipts ============

  @override
  Future<DatecsResponse> openFiscalReceipt({
    OperatorInfo operator = const OperatorInfo(),
    ReceiptType type = ReceiptType.fiscal,
    String? clientTaxNumber,
  }) {
    // Format per FP_Protocol_EN.pdf Command 48:
    // <OpCode><SEP><OpPwd><SEP><TillNmb><SEP><Invoice><SEP><ClientTAXN><SEP>
    // SEP = TAB character
    final taxNum = clientTaxNumber ?? '';
    final data =
        '${operator.code}\t${operator.password}\t${operator.tillNumber}\t\t$taxNum\t';
    return executeCommand(48, data);
  }

  @override
  Future<DatecsResponse> registerSale(SaleItem item) {
    return executeCommand(49, item.toCommandData());
  }

  @override
  Future<DatecsResponse> subtotal({
    bool printText = false,
    bool displayText = false,
    DiscountType discountType = DiscountType.none,
    double discountValue = 0.0,
  }) {
    final printFlag = printText ? '1' : '0';
    final displayFlag = displayText ? '1' : '0';
    final data =
        '$printFlag\t$displayFlag\t${discountType.code}\t$discountValue\t';
    return executeCommand(51, data);
  }

  @override
  Future<DatecsResponse> registerPayment(Payment payment) {
    return executeCommand(53, payment.toCommandData());
  }

  @override
  Future<DatecsResponse> closeFiscalReceipt() => executeCommand(56);

  @override
  Future<DatecsResponse> cancelFiscalReceipt() => executeCommand(60);

  @override
  Future<DatecsResponse> printFiscalText(String text) =>
      executeCommand(54, '$text\t');

  // ============ Non-Fiscal Receipts ============

  @override
  Future<DatecsResponse> openNonFiscalReceipt({
    OperatorInfo operator = const OperatorInfo(),
    bool printHeader = true,
  }) {
    // Format per FP_Protocol_EN.pdf Command 38 (page 10):
    // Syntax 1: none (no parameters)
    // Syntax 2: {Param}<SEP> where Param=1 means "Don't print header lines"
    // NOTE: This command does NOT take operator credentials!
    final data = printHeader ? '' : '1\t';
    return executeCommand(38, data);
  }

  @override
  Future<DatecsResponse> printNonFiscalText(String text) {
    return executeCommand(42, '$text\t');
  }

  @override
  Future<DatecsResponse> closeNonFiscalReceipt() => executeCommand(39);

  // ============ Reports ============

  @override
  Future<DatecsResponse> generateDailyReport(DailyReportType type) {
    return executeCommand(69, type.code);
  }

  // ============ Other ============

  @override
  Future<DatecsResponse> paperFeed([int lines = 1]) =>
      executeCommand(44, '$lines\t');

  @override
  Future<DatecsResponse> paperCut() => executeCommand(46);

  @override
  Future<DatecsResponse> ejectPaper([int feedLines = 5]) async {
    // Feed paper so it comes out of the printer completely
    await paperFeed(feedLines);
    // Cut paper
    // NOTE: SK1-21 does NOT support software-controlled paper presenter.
    // The physical eject button triggers a hardware presenter motor not exposed
    // through the protocol. BackFeedSteps parameter is only for FP-800/FP-650.
    return paperCut();
  }

  @override
  Future<DatecsResponse> openCashDrawer() => executeCommand(106);

  @override
  Future<DatecsResponse> printBarcode(String data, [String type = 'EAN13']) {
    return executeCommand(84, '$type\t$data\t');
  }

  @override
  Future<DatecsResponse> printQRCode(String data, [int size = 4]) {
    return executeCommand(84, 'QR\t$size\t$data\t');
  }

  @override
  Future<DatecsResponse> cashInOut(double amount) {
    return executeCommand(70, '$amount\t');
  }

  // ============ Date/Time Operations ============

  @override
  Future<DatecsResponse> setDateTime(DateTime dateTime) {
    // Format: DD-MM-YY HH:MM:SS
    final data =
        '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${(dateTime.year % 100).toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}\t';
    return executeCommand(61, data);
  }

  @override
  Future<DateTime?> readDateTime() async {
    final response = await executeCommand(62);
    if (response.hasError || response.deviceAnswer.isEmpty) {
      return null;
    }
    try {
      // Parse: DD-MM-YY HH:MM:SS
      final parts = response.deviceAnswer.split(' ');
      final dateParts = parts[0].split('-');
      final timeParts =
          parts.length > 1 ? parts[1].split(':') : ['0', '0', '0'];

      var year = int.parse(dateParts[2]);
      if (year < 100) year += 2000;

      return DateTime(
        year,
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
      );
    } catch (_) {
      return null;
    }
  }

  // ============ VAT/Tax Operations ============

  @override
  Future<DatecsResponse> programVatRates(Map<TaxGroup, double> rates) {
    // Format: rateA\trateB\trateC\trateD\trateE\trateF\trateG\trateH\t
    final ratesList =
        TaxGroup.values.map((g) => rates[g]?.toStringAsFixed(2) ?? '').toList();
    return executeCommand(83, '${ratesList.join('\t')}\t');
  }

  @override
  Future<Map<TaxGroup, double>> readVatRates() async {
    final response = await executeCommand(50);
    final rates = <TaxGroup, double>{};

    if (!response.hasError && response.deviceAnswer.isNotEmpty) {
      final parts = response.deviceAnswer.split('\t');
      for (var i = 0; i < parts.length && i < TaxGroup.values.length; i++) {
        final rate = double.tryParse(parts[i]);
        if (rate != null) {
          rates[TaxGroup.values[i]] = rate;
        }
      }
    }
    return rates;
  }

  // ============ Receipt Information ============

  @override
  Future<ReceiptStatus> getReceiptStatus() async {
    final response = await executeCommand(76);
    return ReceiptStatus.fromResponse(response.deviceAnswer);
  }

  @override
  Future<ReceiptInfo> getCurrentReceiptInfo() async {
    final response = await executeCommand(103);
    return ReceiptInfo.fromResponse(response.deviceAnswer);
  }

  // ============ Fiscal Memory Operations ============

  @override
  Future<int> getRemainingZReports() async {
    final response = await executeCommand(68);
    if (response.hasError) return 0;
    final info = RemainingZReportsInfo.fromResponse(response.deviceAnswer);
    return info.remainingZReports;
  }

  @override
  Future<DateTime?> getLastFiscalRecordDate() async {
    final response = await executeCommand(86);
    if (response.hasError) return null;
    final info = LastFiscalRecordDate.fromResponse(response.deviceAnswer);
    return info.date;
  }

  @override
  Future<FiscalMemoryTestResult> testFiscalMemory() async {
    final response = await executeCommand(89);
    return FiscalMemoryTestResult.fromResponse(response.deviceAnswer);
  }

  @override
  Future<List<FiscalMemoryRecord>> readFiscalMemory(
      int startZ, int endZ) async {
    final records = <FiscalMemoryRecord>[];
    for (var z = startZ; z <= endZ; z++) {
      final response = await executeCommand(116, '$z\t');
      if (!response.hasError && response.deviceAnswer.isNotEmpty) {
        records.add(FiscalMemoryRecord.fromResponse(response.deviceAnswer));
      }
    }
    return records;
  }

  @override
  Future<DatecsResponse> printFiscalReportByDates(
      DateTime startDate, DateTime endDate) {
    final start =
        '${startDate.day.toString().padLeft(2, '0')}-${startDate.month.toString().padLeft(2, '0')}-${(startDate.year % 100).toString().padLeft(2, '0')}';
    final end =
        '${endDate.day.toString().padLeft(2, '0')}-${endDate.month.toString().padLeft(2, '0')}-${(endDate.year % 100).toString().padLeft(2, '0')}';
    return executeCommand(94, '$start\t$end\t');
  }

  @override
  Future<DatecsResponse> printFiscalReportByZNumbers(int startZ, int endZ) {
    return executeCommand(95, '$startZ\t$endZ\t');
  }

  @override
  Future<LastFiscalEntryInfo> getLastFiscalEntryInfo() async {
    final response = await executeCommand(64);
    return LastFiscalEntryInfo.fromResponse(response.deviceAnswer);
  }

  // ============ Electronic Journal Operations ============

  @override
  Future<JournalSearchResult> searchJournalByDate(DateTime date) async {
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${(date.year % 100).toString().padLeft(2, '0')}';
    final response = await executeCommand(124, '$dateStr\t');
    return JournalSearchResult.fromResponse(response.deviceAnswer);
  }

  @override
  Future<JournalInfo> getJournalInfo() async {
    final response = await executeCommand(125);
    return JournalInfo.fromResponse(response.deviceAnswer);
  }

  @override
  Future<DatecsResponse> exportXmlFiles(XmlExportConfig config) {
    return executeCommand(128, config.toCommandData());
  }

  // ============ Programming Operations ============

  @override
  Future<DatecsResponse> programHeaderLine(int lineNumber, String text) {
    return executeCommand(43, '$lineNumber\t$text\t');
  }

  @override
  Future<DatecsResponse> programOperatorPassword(
      int operatorNumber, String oldPassword, String newPassword) {
    return executeCommand(101, '$operatorNumber\t$oldPassword\t$newPassword\t');
  }

  @override
  Future<DatecsResponse> programPluItem(PluItem item) {
    return executeCommand(107, item.toCommandData());
  }

  @override
  Future<PluItem?> readPluItem(int code) async {
    final response = await executeCommand(107, 'R\t$code\t');
    if (response.hasError || response.deviceAnswer.isEmpty) {
      return null;
    }
    return PluItem.fromResponse(response.deviceAnswer);
  }

  @override
  Future<DatecsResponse> deletePluItem(int code) {
    return executeCommand(107, 'D\t$code\t');
  }

  // ============ Sales Operations ============

  @override
  Future<DatecsResponse> sellProgrammedItem(
    int pluCode, {
    double quantity = 1.0,
    DiscountType discountType = DiscountType.none,
    double discountValue = 0.0,
  }) {
    return executeCommand(
        58, '$pluCode\t$quantity\t${discountType.code}\t$discountValue\t');
  }

  @override
  Future<DatecsResponse> printSeparatingLine() {
    return executeCommand(92);
  }

  // ============ Reports ============

  @override
  Future<DatecsResponse> printOperatorsReport() {
    return executeCommand(105);
  }

  @override
  Future<DatecsResponse> printPluReport({int startCode = 0, int endCode = 0}) {
    return executeCommand(111, '$startCode\t$endCode\t');
  }

  @override
  Future<DatecsResponse> printDepartmentsReport() {
    return executeCommand(69, 'D');
  }

  @override
  Future<DatecsResponse> printItemGroupsReport() {
    return executeCommand(69, 'G');
  }

  // ============ Information Queries ============

  @override
  Future<DailyTaxInfo> getDailyTaxationInfo() async {
    final response = await executeCommand(65);
    return DailyTaxInfo.fromResponse(response.deviceAnswer);
  }

  @override
  Future<ItemGroup> getItemGroupInfo(int groupNumber) async {
    final response = await executeCommand(87, '$groupNumber\t');
    return ItemGroup.fromResponse(groupNumber, response.deviceAnswer);
  }

  @override
  Future<Department> getDepartmentInfo(int departmentNumber) async {
    final response = await executeCommand(88, '$departmentNumber\t');
    return Department.fromResponse(departmentNumber, response.deviceAnswer);
  }

  @override
  Future<OperatorData> getOperatorInfo(int operatorNumber) async {
    final response = await executeCommand(112, '$operatorNumber\t');
    return OperatorData.fromResponse(operatorNumber, response.deviceAnswer);
  }

  @override
  Future<AdditionalDailyInfo> getAdditionalDailyInfo() async {
    final response = await executeCommand(110);
    return AdditionalDailyInfo.fromResponse(response.deviceAnswer);
  }

  @override
  Future<String> readTaxNumber() async {
    final response = await executeCommand(99);
    return response.deviceAnswer.trim();
  }

  @override
  Future<DeviceInfo> getDeviceFullInfo() async {
    final response = await executeCommand(123);
    if (response.hasError) {
      return DeviceInfo(
        model: 'Unknown',
        serialNumber: '',
        firmwareVersion: '',
        codePage: '',
        distributor: '',
        isFiscalPrinter: false,
      );
    }
    final parts = response.deviceAnswer.split('\t');
    return DeviceInfo(
      model: parts.isNotEmpty ? parts[0] : 'Unknown',
      serialNumber: parts.length > 1 ? parts[1] : '',
      firmwareVersion: parts.length > 2 ? parts[2] : '',
      codePage: parts.length > 3 ? parts[3] : '1251',
      distributor: parts.length > 4 ? parts[4] : 'Datecs',
      isFiscalPrinter: parts.length > 5 ? parts[5] == '1' : true,
    );
  }

  @override
  Future<String> readLastError() async {
    final response = await executeCommand(100);
    return response.deviceAnswer.trim();
  }

  // ============ Display & Sound ============

  @override
  Future<DatecsResponse> playSound(int frequency, int duration) {
    return executeCommand(80, '$frequency\t$duration\t');
  }

  // ============ Graphics Operations ============

  @override
  Future<DatecsResponse> loadLogo(Uint8List imageData) {
    // Convert image data to base64 for transmission
    final base64Data = base64Encode(imageData);
    return executeCommand(202, '$base64Data\t');
  }

  @override
  Future<DatecsResponse> loadStampImage(int position, Uint8List imageData) {
    final base64Data = base64Encode(imageData);
    return executeCommand(203, '$position\t$base64Data\t');
  }

  @override
  Future<DatecsResponse> printStamp(int position) {
    return executeCommand(127, '$position\t');
  }

  // ============ Parameter Configuration ============

  @override
  Future<String> readParameter(int paramNumber) async {
    final response = await executeCommand(255, 'R\t$paramNumber\t');
    return response.deviceAnswer.trim();
  }

  @override
  Future<DatecsResponse> writeParameter(int paramNumber, String value) {
    return executeCommand(255, 'W\t$paramNumber\t$value\t');
  }

  // ============ Service Operations ============

  @override
  Future<DatecsResponse> fiscalize(String taxNumber, String fiscalNumber) {
    return executeCommand(72, '$taxNumber\t$fiscalNumber\t');
  }

  @override
  Future<DatecsResponse> programSerialNumber(String serialNumber) {
    return executeCommand(91, '$serialNumber\t');
  }

  @override
  Future<DatecsResponse> switchMode(PrinterMode mode) {
    return executeCommand(149, '${mode.code}\t');
  }

  @override
  Future<DatecsResponse> serviceOperation(int operation, String data) {
    return executeCommand(253, '$operation\t$data\t');
  }
}
