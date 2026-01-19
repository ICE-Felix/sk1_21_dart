/// Error codes for Datecs SK1-21 fiscal printer.
/// Based on FP_Protocol_EN.pdf and ErrorCodes documentation.

/// Datecs printer error codes enumeration.
enum DatecsErrorCode {
  /// No error - operation successful.
  success(0, 'No error'),

  /// Syntax error in command.
  syntaxError(1, 'Syntax error in command'),

  /// Invalid command code.
  invalidCommand(2, 'Invalid command code'),

  /// Clock not set.
  clockNotSet(3, 'Clock not set'),

  /// No authorization for this command.
  noAuthorization(4, 'No authorization for this command'),

  /// Wrong password.
  wrongPassword(5, 'Wrong password'),

  /// Receipt already open.
  receiptAlreadyOpen(6, 'Receipt already open'),

  /// No receipt open.
  noReceiptOpen(7, 'No receipt open'),

  /// Payment already started.
  paymentStarted(8, 'Payment already started'),

  /// Wrong date.
  wrongDate(9, 'Wrong date'),

  /// Amount too large.
  amountTooLarge(10, 'Amount too large'),

  /// Insufficient payment.
  insufficientPayment(11, 'Insufficient payment'),

  /// VAT rates not set.
  vatRatesNotSet(12, 'VAT rates not set'),

  /// Serial number not set.
  serialNumberNotSet(13, 'Serial number not set'),

  /// Fiscal memory error.
  fiscalMemoryError(14, 'Fiscal memory error'),

  /// Fiscal memory full.
  fiscalMemoryFull(15, 'Fiscal memory full'),

  /// Daily report required.
  dailyReportRequired(16, 'Daily report required (Z-report needed)'),

  /// RAM error.
  ramError(17, 'RAM error'),

  /// Paper out.
  paperOut(18, 'Paper out'),

  /// Print head overheat.
  printHeadOverheat(19, 'Print head overheat'),

  /// Cutter error.
  cutterError(20, 'Cutter error'),

  /// Cover open.
  coverOpen(21, 'Cover open'),

  /// Printer error.
  printerError(22, 'Printer error'),

  /// Display not connected.
  displayNotConnected(23, 'Display not connected'),

  /// Drawer open.
  drawerOpen(24, 'Drawer open'),

  /// Wrong department.
  wrongDepartment(25, 'Wrong department number'),

  /// Wrong tax group.
  wrongTaxGroup(26, 'Wrong tax group'),

  /// Item not found.
  itemNotFound(27, 'Item not found'),

  /// Item already exists.
  itemAlreadyExists(28, 'Item already exists'),

  /// Quantity too large.
  quantityTooLarge(29, 'Quantity too large'),

  /// Price too large.
  priceTooLarge(30, 'Price too large'),

  /// Negative not allowed.
  negativeNotAllowed(31, 'Negative value not allowed'),

  /// Discount too large.
  discountTooLarge(32, 'Discount value too large'),

  /// No sale registered.
  noSaleRegistered(33, 'No sale registered'),

  /// Total payment required.
  totalPaymentRequired(34, 'Total payment required before close'),

  /// Void not allowed.
  voidNotAllowed(35, 'Void operation not allowed'),

  /// Fiscal receipt required.
  fiscalReceiptRequired(36, 'Fiscal receipt required'),

  /// Non-fiscal receipt required.
  nonFiscalReceiptRequired(37, 'Non-fiscal receipt required'),

  /// Operator not found.
  operatorNotFound(38, 'Operator not found'),

  /// Text too long.
  textTooLong(39, 'Text too long'),

  /// Barcode invalid.
  barcodeInvalid(40, 'Invalid barcode format'),

  /// Communication error.
  communicationError(50, 'Communication error'),

  /// Timeout.
  timeout(51, 'Timeout'),

  /// Connection lost.
  connectionLost(52, 'Connection lost'),

  /// Device busy.
  deviceBusy(53, 'Device busy'),

  /// Not fiscalized.
  notFiscalized(60, 'Device not fiscalized'),

  /// Already fiscalized.
  alreadyFiscalized(61, 'Device already fiscalized'),

  /// Service mode required.
  serviceModeRequired(62, 'Service mode required'),

  /// Invalid parameter.
  invalidParameter(70, 'Invalid parameter value'),

  /// Parameter out of range.
  parameterOutOfRange(71, 'Parameter out of range'),

  /// Read only parameter.
  readOnlyParameter(72, 'Parameter is read-only'),

  /// Electronic journal error.
  journalError(80, 'Electronic journal error'),

  /// Electronic journal full.
  journalFull(81, 'Electronic journal full'),

  /// Logo too large.
  logoTooLarge(90, 'Logo image too large'),

  /// Invalid image format.
  invalidImageFormat(91, 'Invalid image format'),

  /// General error.
  generalError(99, 'General error'),

  // ============ DUDE Driver Specific Errors ============
  // These are returned by the DUDE COM driver, not the printer itself

  /// DUDE: Port not found or cannot be opened.
  dudePortError(-100001, 'DUDE: Port not found or cannot be opened'),

  /// DUDE: Port already open.
  dudePortAlreadyOpen(-100002, 'DUDE: Port already open'),

  /// DUDE: Communication timeout.
  dudeTimeout(-100003, 'DUDE: Communication timeout'),

  /// DUDE: No response from device.
  dudeNoResponse(-100004, 'DUDE: No response from device'),

  /// DUDE: Invalid response format.
  dudeInvalidResponse(-100005, 'DUDE: Invalid response format'),

  /// DUDE: Checksum error.
  dudeChecksumError(-100006, 'DUDE: Checksum error'),

  /// DUDE: Command not supported.
  dudeCommandNotSupported(-100007, 'DUDE: Command not supported'),

  /// DUDE: Device busy.
  dudeDeviceBusy(-100008, 'DUDE: Device busy'),

  /// DUDE: Parameter error.
  dudeParameterError(-112001, 'DUDE: Parameter not available or error'),

  /// DUDE: Non-fiscal receipt not open (trying to close/print when no receipt is open).
  dudeNonFiscalNotOpen(-111016,
      'DUDE: Non-fiscal receipt not open - must open receipt first with Command 38'),

  /// DUDE: Non-fiscal receipt error (wrong state or not allowed).
  dudeNonFiscalError(-112101,
      'DUDE: Non-fiscal receipt operation failed - receipt may already be open or wrong state'),

  /// DUDE: Connection error.
  dudeConnectionError(-100010, 'DUDE: Connection error'),

  /// DUDE/Exception: General error or exception occurred.
  dudeException(-1, 'DUDE: Exception or general error'),

  /// Unknown error (shows raw code).
  unknown(-999999, 'Unknown error');

  /// The numeric error code.
  final int code;

  /// Human-readable description.
  final String description;

  const DatecsErrorCode(this.code, this.description);

  /// Get error code from numeric value.
  static DatecsErrorCode fromCode(int code) {
    for (final error in DatecsErrorCode.values) {
      if (error.code == code) {
        return error;
      }
    }
    return DatecsErrorCode.unknown;
  }

  /// Check if this is a critical error that stops operation.
  bool get isCritical =>
      this == fiscalMemoryError ||
      this == fiscalMemoryFull ||
      this == ramError ||
      this == printerError ||
      this == journalError ||
      this == journalFull;

  /// Check if this is a paper-related error.
  bool get isPaperError => this == paperOut;

  /// Check if this is a hardware error.
  bool get isHardwareError =>
      this == paperOut ||
      this == printHeadOverheat ||
      this == cutterError ||
      this == coverOpen ||
      this == printerError;

  /// Check if this is a communication error.
  bool get isCommunicationError =>
      this == communicationError || this == timeout || this == connectionLost;

  @override
  String toString() => 'DatecsErrorCode.$name($code: $description)';
}

/// Extension to parse error from response.
extension DatecsErrorCodeParsing on int {
  /// Convert error code number to DatecsErrorCode.
  DatecsErrorCode toDatecsError() => DatecsErrorCode.fromCode(this);
}
