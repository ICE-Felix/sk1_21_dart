import 'dart:async';
import 'dart:typed_data';
import 'models/models.dart';

/// Response from Datecs printer - fully parsed.
class DatecsResponse {
  /// Numeric error code (0 = success).
  final int errorCode;

  /// Error parsed as DatecsErrorCode object.
  late final DatecsErrorCode error;

  /// Raw device response.
  final String deviceAnswer;

  /// True if command succeeded.
  final bool success;

  /// Printer status (parsed from status bytes).
  final PrinterStatus? printerStatus;

  /// Main constructor with automatic error parsing.
  DatecsResponse({
    required this.errorCode,
    required this.deviceAnswer,
    required this.success,
    this.printerStatus,
  }) {
    error = DatecsErrorCode.fromCode(errorCode);
  }

  /// True if there is an error.
  bool get hasError => errorCode != 0;

  /// Error description in English.
  /// If error is unknown, includes the raw error code for debugging.
  String get errorDescription {
    if (error == DatecsErrorCode.unknown) {
      return 'Unknown error (code: $errorCode)';
    }
    return error.description;
  }

  /// True if the error is critical (stops operation).
  bool get isCriticalError => error.isCritical;

  /// True if it's a paper error.
  bool get isPaperError => error.isPaperError;

  /// True if it's a hardware error.
  bool get isHardwareError => error.isHardwareError;

  /// True if it's a communication error.
  bool get isCommunicationError => error.isCommunicationError;

  /// Parse response into TAB-separated fields.
  List<String> get fields => deviceAnswer.split('\t');

  /// Get a field as String (null if index doesn't exist).
  String? getField(int index) {
    final f = fields;
    return index < f.length && f[index].isNotEmpty ? f[index] : null;
  }

  /// Get a field as int (null if cannot be parsed).
  int? getFieldAsInt(int index) {
    final value = getField(index);
    return value != null ? int.tryParse(value) : null;
  }

  /// Get a field as double (null if cannot be parsed).
  double? getFieldAsDouble(int index) {
    final value = getField(index);
    return value != null ? double.tryParse(value) : null;
  }

  @override
  String toString() => success
      ? 'DatecsResponse(success, answer: $deviceAnswer)'
      : 'DatecsResponse(error: ${error.name} - ${error.description})';
}

/// Abstract interface for Datecs printer communication.
///
/// Available implementation:
/// - [DatecsDudeDriver] - Direct DUDE COM communication via PowerShell
abstract class DatecsDriver {
  // ============ Connection State ============

  /// True if COM server is started.
  bool get isServerStarted;

  /// True if there is an active connection to the printer.
  bool get isConnected;

  /// Information about connected device.
  DeviceInfo? get deviceInfo;

  // ============ Events ============

  /// Error stream.
  Stream<String> get onError;

  /// Status change stream.
  Stream<int> get onStatusChange;

  /// Sent commands stream.
  Stream<String> get onCommandSent;

  /// Received responses stream.
  Stream<String> get onAnswerReceived;

  // ============ Lifecycle ============

  /// Start the COM server (DUDE).
  ///
  /// Equivalent to the "Start - COM Server" button in the C# application.
  /// This step initializes the DUDE driver in memory, but does NOT open
  /// any physical connection.
  Future<void> startComServer();

  /// Open RS232 connection.
  ///
  /// [config] - Serial port configuration (COM port and baud rate).
  ///
  /// Equivalent to configuration + "Open Connection" button in C#.
  Future<void> openRs232Connection(Rs232Config config);

  /// Open TCP/IP connection.
  ///
  /// [config] - Network connection configuration.
  Future<void> openTcpIpConnection(TcpIpConfig config);

  /// Close current connection.
  Future<void> closeConnection();

  /// Stop COM server.
  Future<void> stopComServer();

  /// Release resources.
  void dispose();

  // ============ Raw Commands ============

  /// Execute a raw command.
  ///
  /// [command] - Command number (e.g.: 48, 49, 53, 56).
  /// [data] - Command data (TAB-separated parameters).
  Future<DatecsResponse> executeCommand(int command, [String data = '']);

  // ============ Basic Commands ============

  /// Get diagnostic information (Command 90).
  /// Returns DiagnosticInfo object with firmware, serial, RAM, etc.
  Future<DiagnosticInfo> getDiagnosticInfo();

  /// Read complete printer status (Command 74).
  /// Returns PrinterStatus object with all parsed flags.
  Future<PrinterStatus> getStatus();

  /// Check connection (Command 45).
  Future<DatecsResponse> checkConnection();

  /// Print diagnostic information (Command 71).
  Future<DatecsResponse> printDiagnostic();

  // ============ Display ============

  /// Clear display (Command 33).
  Future<DatecsResponse> clearDisplay();

  /// Display text on upper line (Command 47).
  Future<DatecsResponse> displayUpperLine(String text);

  /// Display text on lower line (Command 35).
  Future<DatecsResponse> displayLowerLine(String text);

  // ============ Fiscal Receipts ============

  /// Open a fiscal receipt (Command 48).
  ///
  /// [operator] - Operator information.
  /// [type] - Receipt type (fiscal, invoice, etc).
  /// [clientTaxNumber] - Client tax ID (optional, for invoices).
  Future<DatecsResponse> openFiscalReceipt({
    OperatorInfo operator = const OperatorInfo(),
    ReceiptType type = ReceiptType.fiscal,
    String? clientTaxNumber,
  });

  /// Register a sale (Command 49).
  ///
  /// [item] - Item to sell.
  Future<DatecsResponse> registerSale(SaleItem item);

  /// Calculate subtotal (Command 51).
  ///
  /// [printText] - True to print subtotal.
  /// [displayText] - True to display on screen.
  /// [discountType] - Discount type on subtotal.
  /// [discountValue] - Discount value.
  Future<DatecsResponse> subtotal({
    bool printText = false,
    bool displayText = false,
    DiscountType discountType = DiscountType.none,
    double discountValue = 0.0,
  });

  /// Register payment and total (Command 53).
  ///
  /// [payment] - Payment information.
  Future<DatecsResponse> registerPayment(Payment payment);

  /// Close fiscal receipt (Command 56).
  Future<DatecsResponse> closeFiscalReceipt();

  /// Cancel current fiscal receipt (Command 60).
  Future<DatecsResponse> cancelFiscalReceipt();

  /// Print fiscal text (Command 54).
  Future<DatecsResponse> printFiscalText(String text);

  // ============ Non-Fiscal Receipts ============

  /// Open a non-fiscal receipt (Command 38).
  ///
  /// [operator] - Operator information (not used per protocol, kept for API compatibility).
  /// [printHeader] - If false, header lines are not printed.
  Future<DatecsResponse> openNonFiscalReceipt({
    OperatorInfo operator = const OperatorInfo(),
    bool printHeader = true,
  });

  /// Print non-fiscal text (Command 42).
  ///
  /// [text] - Text to print (max 42 characters).
  Future<DatecsResponse> printNonFiscalText(String text);

  /// Close non-fiscal receipt (Command 39).
  Future<DatecsResponse> closeNonFiscalReceipt();

  // ============ Reports ============

  /// Generate daily report (Command 69).
  ///
  /// [type] - Report type (X, Z, ECR, etc).
  Future<DatecsResponse> generateDailyReport(DailyReportType type);

  /// Generate X report (preview, no closure).
  Future<DatecsResponse> generateXReport() =>
      generateDailyReport(DailyReportType.xReport);

  /// Generate Z report (daily closure).
  ///
  /// WARNING: This report can only be generated ONCE PER DAY!
  Future<DatecsResponse> generateZReport() =>
      generateDailyReport(DailyReportType.zReport);

  // ============ Other ============

  /// Paper feed (Command 44).
  ///
  /// [lines] - Number of lines.
  Future<DatecsResponse> paperFeed([int lines = 1]);

  /// Paper cut (Command 46).
  Future<DatecsResponse> paperCut();

  /// Eject receipt - performs feed + cut.
  ///
  /// [feedLines] - Number of lines to feed before cutting.
  ///
  /// NOTE: On SK1-21, this only feeds and cuts. The paper presenter (which
  /// pushes paper out like the physical button) is hardware-controlled only.
  /// The BackFeedSteps parameter is only available on FP-800 and FP-650 models.
  Future<DatecsResponse> ejectPaper([int feedLines = 5]);

  /// Open cash drawer (Command 106).
  Future<DatecsResponse> openCashDrawer();

  /// Print barcode (Command 84).
  ///
  /// [data] - Barcode data.
  /// [type] - Barcode type (EAN13, Code128, etc).
  Future<DatecsResponse> printBarcode(String data, [String type = 'EAN13']);

  /// Print QR code (Command 84).
  ///
  /// [data] - QR code data.
  /// [size] - Size (1-10).
  Future<DatecsResponse> printQRCode(String data, [int size = 4]);

  /// Cash in/out operations (Command 70).
  ///
  /// [amount] - Amount (positive for cash-in, negative for cash-out).
  Future<DatecsResponse> cashInOut(double amount);

  // ============ Date/Time Operations ============

  /// Set printer date and time (Command 61).
  ///
  /// [dateTime] - The date and time to set.
  Future<DatecsResponse> setDateTime(DateTime dateTime);

  /// Read current date and time (Command 62).
  ///
  /// Returns the current date/time from the printer.
  Future<DateTime?> readDateTime();

  // ============ VAT/Tax Operations ============

  /// Program VAT rates (Command 83).
  ///
  /// [rates] - Map of tax groups to their VAT rates.
  /// Note: This operation may require service mode.
  Future<DatecsResponse> programVatRates(Map<TaxGroup, double> rates);

  /// Read current VAT rates (Command 50).
  ///
  /// Returns a map of tax groups to their configured rates.
  Future<Map<TaxGroup, double>> readVatRates();

  // ============ Receipt Information ============

  /// Get current receipt status (Command 76).
  ///
  /// Returns detailed receipt status including open state and subtotal.
  Future<ReceiptStatus> getReceiptStatus();

  /// Get current receipt information (Command 103).
  ///
  /// Returns detailed info about the currently open receipt.
  Future<ReceiptInfo> getCurrentReceiptInfo();

  // ============ Fiscal Memory Operations ============

  /// Get remaining Z-reports in fiscal memory (Command 68).
  ///
  /// Returns the number of available Z-report slots.
  Future<int> getRemainingZReports();

  /// Get date of last fiscal record (Command 86).
  ///
  /// Returns the date of the most recent fiscal memory entry.
  Future<DateTime?> getLastFiscalRecordDate();

  /// Test fiscal memory integrity (Command 89).
  ///
  /// Performs a diagnostic test on the fiscal memory.
  Future<FiscalMemoryTestResult> testFiscalMemory();

  /// Read fiscal memory records (Command 116).
  ///
  /// [startZ] - Starting Z-report number.
  /// [endZ] - Ending Z-report number.
  Future<List<FiscalMemoryRecord>> readFiscalMemory(int startZ, int endZ);

  /// Print fiscal memory report by date range (Command 94).
  ///
  /// [startDate] - Start date.
  /// [endDate] - End date.
  Future<DatecsResponse> printFiscalReportByDates(
      DateTime startDate, DateTime endDate);

  /// Print fiscal memory report by Z-report numbers (Command 95).
  ///
  /// [startZ] - Starting Z-report number.
  /// [endZ] - Ending Z-report number.
  Future<DatecsResponse> printFiscalReportByZNumbers(int startZ, int endZ);

  /// Get last fiscal entry information (Command 64).
  ///
  /// Returns info about the last Z-report and receipts since.
  Future<LastFiscalEntryInfo> getLastFiscalEntryInfo();

  // ============ Electronic Journal Operations ============

  /// Search electronic journal by date (Command 124).
  ///
  /// [date] - The date to search for.
  Future<JournalSearchResult> searchJournalByDate(DateTime date);

  /// Get electronic journal information (Command 125).
  ///
  /// Returns storage and record information.
  Future<JournalInfo> getJournalInfo();

  /// Export data to XML files (Command 128).
  ///
  /// [config] - Export configuration.
  Future<DatecsResponse> exportXmlFiles(XmlExportConfig config);

  // ============ Programming Operations ============

  /// Program header line (Command 43).
  ///
  /// [lineNumber] - Line number (1-6).
  /// [text] - Text to set (max 42 chars).
  Future<DatecsResponse> programHeaderLine(int lineNumber, String text);

  /// Change operator password (Command 101).
  ///
  /// [operatorNumber] - Operator number (1-30).
  /// [oldPassword] - Current password.
  /// [newPassword] - New password.
  Future<DatecsResponse> programOperatorPassword(
      int operatorNumber, String oldPassword, String newPassword);

  /// Program a PLU item (Command 107 - write).
  ///
  /// [item] - The PLU item to program.
  Future<DatecsResponse> programPluItem(PluItem item);

  /// Read a PLU item (Command 107 - read).
  ///
  /// [code] - PLU code to read.
  Future<PluItem?> readPluItem(int code);

  /// Delete a PLU item (Command 107 - delete).
  ///
  /// [code] - PLU code to delete.
  Future<DatecsResponse> deletePluItem(int code);

  // ============ Sales Operations ============

  /// Sell a programmed PLU item (Command 58).
  ///
  /// [pluCode] - The PLU code to sell.
  /// [quantity] - Quantity to sell.
  /// [discountType] - Optional discount type.
  /// [discountValue] - Optional discount value.
  Future<DatecsResponse> sellProgrammedItem(
    int pluCode, {
    double quantity = 1.0,
    DiscountType discountType = DiscountType.none,
    double discountValue = 0.0,
  });

  /// Print a separating line (Command 92).
  ///
  /// Prints a horizontal separator line on the receipt.
  Future<DatecsResponse> printSeparatingLine();

  // ============ Reports ============

  /// Print operators report (Command 105).
  ///
  /// Prints sales statistics for all operators.
  Future<DatecsResponse> printOperatorsReport();

  /// Print PLU report (Command 111).
  ///
  /// [startCode] - Starting PLU code (0 for all).
  /// [endCode] - Ending PLU code (0 for all).
  Future<DatecsResponse> printPluReport({int startCode = 0, int endCode = 0});

  /// Print departments report (Command 69 type 3).
  Future<DatecsResponse> printDepartmentsReport();

  /// Print item groups report (Command 69 type 4).
  Future<DatecsResponse> printItemGroupsReport();

  // ============ Information Queries ============

  /// Get daily taxation information (Command 65).
  ///
  /// Returns sales and VAT totals by tax group.
  Future<DailyTaxInfo> getDailyTaxationInfo();

  /// Get item group information (Command 87).
  ///
  /// [groupNumber] - Group number (1-99).
  Future<ItemGroup> getItemGroupInfo(int groupNumber);

  /// Get department information (Command 88).
  ///
  /// [departmentNumber] - Department number (1-99).
  Future<Department> getDepartmentInfo(int departmentNumber);

  /// Get operator information (Command 112).
  ///
  /// [operatorNumber] - Operator number (1-30).
  Future<OperatorData> getOperatorInfo(int operatorNumber);

  /// Get additional daily information (Command 110).
  ///
  /// Returns cash drawer and payment type statistics.
  Future<AdditionalDailyInfo> getAdditionalDailyInfo();

  /// Read tax number (Command 99).
  ///
  /// Returns the programmed tax identification number (CUI/CIF).
  Future<String> readTaxNumber();

  /// Get full device information (Command 123).
  ///
  /// Returns comprehensive device info.
  Future<DeviceInfo> getDeviceFullInfo();

  /// Read last error (Command 100).
  ///
  /// Returns the last error message from the printer.
  Future<String> readLastError();

  // ============ Display & Sound ============

  /// Play a sound/beep (Command 80).
  ///
  /// [frequency] - Sound frequency in Hz.
  /// [duration] - Duration in milliseconds.
  Future<DatecsResponse> playSound(int frequency, int duration);

  // ============ Graphics Operations ============

  /// Load logo image (Command 202).
  ///
  /// [imageData] - Logo image data (BMP format).
  Future<DatecsResponse> loadLogo(Uint8List imageData);

  /// Load stamp image (Command 203).
  ///
  /// [position] - Stamp position (1-4).
  /// [imageData] - Stamp image data.
  Future<DatecsResponse> loadStampImage(int position, Uint8List imageData);

  /// Print a stamp (Command 127).
  ///
  /// [position] - Stamp position to print (1-4).
  Future<DatecsResponse> printStamp(int position);

  // ============ Parameter Configuration ============

  /// Read a configuration parameter (Command 255).
  ///
  /// [paramNumber] - Parameter number to read.
  Future<String> readParameter(int paramNumber);

  /// Write a configuration parameter (Command 255).
  ///
  /// [paramNumber] - Parameter number to write.
  /// [value] - Value to set.
  Future<DatecsResponse> writeParameter(int paramNumber, String value);

  // ============ Service Operations ============

  /// Fiscalize the device (Command 72).
  ///
  /// [taxNumber] - Tax identification number (CUI/CIF).
  /// [fiscalNumber] - Fiscal serial number.
  /// Note: This is a one-time operation!
  Future<DatecsResponse> fiscalize(String taxNumber, String fiscalNumber);

  /// Program device serial number (Command 91).
  ///
  /// [serialNumber] - Serial number to program.
  /// Note: Usually done in factory.
  Future<DatecsResponse> programSerialNumber(String serialNumber);

  /// Switch printer mode (Command 149).
  ///
  /// [mode] - Target mode.
  Future<DatecsResponse> switchMode(PrinterMode mode);

  /// Execute service operation (Command 253).
  ///
  /// [operation] - Operation code.
  /// [data] - Operation data.
  Future<DatecsResponse> serviceOperation(int operation, String data);

  // ============ Helper Methods ============

  /// Print a simple fiscal receipt.
  ///
  /// [items] - List of items.
  /// [payment] - Payment.
  /// [operator] - Operator.
  Future<bool> printFiscalReceipt({
    required List<SaleItem> items,
    Payment payment = const Payment(type: PaymentType.cash),
    OperatorInfo operator = const OperatorInfo(),
  }) async {
    // Open receipt
    var response = await openFiscalReceipt(operator: operator);
    if (response.hasError) {
      return false;
    }

    // Register items
    for (final item in items) {
      response = await registerSale(item);
      if (response.hasError) {
        await cancelFiscalReceipt();
        return false;
      }
    }

    // Payment
    response = await registerPayment(payment);
    if (response.hasError) {
      await cancelFiscalReceipt();
      return false;
    }

    // Close receipt
    response = await closeFiscalReceipt();
    return !response.hasError;
  }

  /// Print a non-fiscal receipt with text.
  ///
  /// [lines] - Text lines.
  /// [operator] - Operator.
  Future<bool> printNonFiscalReceipt({
    required List<String> lines,
    OperatorInfo operator = const OperatorInfo(),
  }) async {
    // Open non-fiscal receipt
    var response = await openNonFiscalReceipt(operator: operator);
    if (response.hasError) {
      return false;
    }

    // Print lines
    for (final line in lines) {
      response = await printNonFiscalText(line);
      if (response.hasError) {
        return false;
      }
    }

    // Close receipt
    response = await closeNonFiscalReceipt();
    return !response.hasError;
  }
}
