/// Printer status models for Datecs SK1-21.
/// Based on FP_Protocol_EN.pdf - Status byte definitions.

/// Parsed printer status from the 8 status bytes.
class PrinterStatus {
  // Status byte 0 (S0)
  final bool syntaxError;
  final bool invalidCommand;
  final bool clockNotSet;
  final bool commandNotPermitted;
  final bool generalError;

  // Status byte 1 (S1)
  final bool printerOverflow;
  final bool commandBufferFull;
  final bool printingDenied;
  final bool zeroNotResettable;
  final bool printerBufferFull;

  // Status byte 2 (S2)
  final bool paperOut;
  final bool paperNearEnd;
  final bool printHeadOverheat;
  final bool coverOpen;

  // Status byte 3 (S3)
  final bool nonFiscalReceiptOpen;
  final bool fiscalReceiptOpen;
  final bool vatRatesProgrammed;
  final bool printError;
  final bool lessThan50ZReports;

  // Status byte 4 (S4)
  final bool fiscalized;
  final bool serialNumberSet;
  final bool taxNumberSet;
  final bool fiscalMemoryReady;
  final bool fiscalMemoryNearFull;
  final bool fiscalMemoryFull;
  final bool serviceRequired;

  // Status byte 5 (S5)
  final bool displayConnected;
  final bool drawerOpen;
  final bool externalDeviceConnected;

  const PrinterStatus({
    // S0
    this.syntaxError = false,
    this.invalidCommand = false,
    this.clockNotSet = false,
    this.commandNotPermitted = false,
    this.generalError = false,
    // S1
    this.printerOverflow = false,
    this.commandBufferFull = false,
    this.printingDenied = false,
    this.zeroNotResettable = false,
    this.printerBufferFull = false,
    // S2
    this.paperOut = false,
    this.paperNearEnd = false,
    this.printHeadOverheat = false,
    this.coverOpen = false,
    // S3
    this.nonFiscalReceiptOpen = false,
    this.fiscalReceiptOpen = false,
    this.vatRatesProgrammed = false,
    this.printError = false,
    this.lessThan50ZReports = false,
    // S4
    this.fiscalized = false,
    this.serialNumberSet = false,
    this.taxNumberSet = false,
    this.fiscalMemoryReady = false,
    this.fiscalMemoryNearFull = false,
    this.fiscalMemoryFull = false,
    this.serviceRequired = false,
    // S5
    this.displayConnected = false,
    this.drawerOpen = false,
    this.externalDeviceConnected = false,
  });

  /// Check if printer has any error condition.
  bool get hasError =>
      syntaxError ||
      invalidCommand ||
      clockNotSet ||
      commandNotPermitted ||
      generalError ||
      printerOverflow ||
      printError ||
      printHeadOverheat;

  /// Check if printer is ready to print.
  bool get isReady =>
      !paperOut && !coverOpen && !printHeadOverheat && !hasError;

  /// Check if a receipt is currently open.
  bool get receiptOpen => fiscalReceiptOpen || nonFiscalReceiptOpen;

  /// Parse status from 8 status bytes.
  factory PrinterStatus.fromBytes(List<int> bytes) {
    if (bytes.length < 6) {
      return const PrinterStatus();
    }

    final s0 = bytes[0];
    final s1 = bytes[1];
    final s2 = bytes[2];
    final s3 = bytes[3];
    final s4 = bytes[4];
    final s5 = bytes[5];

    return PrinterStatus(
      // S0
      syntaxError: (s0 & 0x01) != 0,
      invalidCommand: (s0 & 0x02) != 0,
      clockNotSet: (s0 & 0x04) != 0,
      commandNotPermitted: (s0 & 0x10) != 0,
      generalError: (s0 & 0x20) != 0,
      // S1
      printerOverflow: (s1 & 0x01) != 0,
      commandBufferFull: (s1 & 0x02) != 0,
      printingDenied: (s1 & 0x04) != 0,
      zeroNotResettable: (s1 & 0x08) != 0,
      printerBufferFull: (s1 & 0x10) != 0,
      // S2
      paperOut: (s2 & 0x01) != 0,
      paperNearEnd: (s2 & 0x02) != 0,
      printHeadOverheat: (s2 & 0x04) != 0,
      coverOpen: (s2 & 0x20) != 0,
      // S3
      nonFiscalReceiptOpen: (s3 & 0x01) != 0,
      fiscalReceiptOpen: (s3 & 0x02) != 0,
      vatRatesProgrammed: (s3 & 0x08) != 0,
      printError: (s3 & 0x10) != 0,
      lessThan50ZReports: (s3 & 0x20) != 0,
      // S4
      fiscalized: (s4 & 0x01) != 0,
      serialNumberSet: (s4 & 0x02) != 0,
      taxNumberSet: (s4 & 0x04) != 0,
      fiscalMemoryReady: (s4 & 0x08) != 0,
      fiscalMemoryNearFull: (s4 & 0x10) != 0,
      fiscalMemoryFull: (s4 & 0x20) != 0,
      serviceRequired: (s4 & 0x40) != 0,
      // S5
      displayConnected: (s5 & 0x01) != 0,
      drawerOpen: (s5 & 0x02) != 0,
      externalDeviceConnected: (s5 & 0x04) != 0,
    );
  }

  @override
  String toString() => '''PrinterStatus(
  hasError: $hasError, isReady: $isReady,
  fiscalReceiptOpen: $fiscalReceiptOpen,
  nonFiscalReceiptOpen: $nonFiscalReceiptOpen,
  paperOut: $paperOut, paperNearEnd: $paperNearEnd,
  fiscalized: $fiscalized, drawerOpen: $drawerOpen
)''';
}

/// Receipt status information (Command 76 response).
class ReceiptStatus {
  /// True if receipt is open.
  final bool isOpen;

  /// Number of sales in current receipt.
  final int salesCount;

  /// Current subtotal.
  final double subtotal;

  /// Is it a fiscal receipt.
  final bool isFiscal;

  /// Receipt number.
  final int receiptNumber;

  const ReceiptStatus({
    this.isOpen = false,
    this.salesCount = 0,
    this.subtotal = 0.0,
    this.isFiscal = false,
    this.receiptNumber = 0,
  });

  /// Parse from command 76 response.
  factory ReceiptStatus.fromResponse(String response) {
    final parts = response.split('\t');
    return ReceiptStatus(
      isOpen: parts.isNotEmpty && parts[0] == '1',
      salesCount: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      subtotal: parts.length > 2 ? double.tryParse(parts[2]) ?? 0.0 : 0.0,
      isFiscal: parts.length > 3 && parts[3] == '1',
      receiptNumber: parts.length > 4 ? int.tryParse(parts[4]) ?? 0 : 0,
    );
  }

  @override
  String toString() =>
      'ReceiptStatus(open: $isOpen, sales: $salesCount, subtotal: $subtotal)';
}

/// Current receipt information (Command 103 response).
class ReceiptInfo {
  /// True if receipt is open.
  final bool isOpen;

  /// Number of sales.
  final int salesCount;

  /// Subtotal without VAT.
  final double subtotalNet;

  /// Total VAT.
  final double totalVat;

  /// Total with VAT.
  final double totalGross;

  /// Fiscal receipt number.
  final int receiptNumber;

  /// Unique sale number (USN).
  final String uniqueSaleNumber;

  const ReceiptInfo({
    this.isOpen = false,
    this.salesCount = 0,
    this.subtotalNet = 0.0,
    this.totalVat = 0.0,
    this.totalGross = 0.0,
    this.receiptNumber = 0,
    this.uniqueSaleNumber = '',
  });

  /// Parse from command 103 response.
  factory ReceiptInfo.fromResponse(String response) {
    final parts = response.split('\t');
    return ReceiptInfo(
      isOpen: parts.isNotEmpty && parts[0] == '1',
      salesCount: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      subtotalNet: parts.length > 2 ? double.tryParse(parts[2]) ?? 0.0 : 0.0,
      totalVat: parts.length > 3 ? double.tryParse(parts[3]) ?? 0.0 : 0.0,
      totalGross: parts.length > 4 ? double.tryParse(parts[4]) ?? 0.0 : 0.0,
      receiptNumber: parts.length > 5 ? int.tryParse(parts[5]) ?? 0 : 0,
      uniqueSaleNumber: parts.length > 6 ? parts[6] : '',
    );
  }

  @override
  String toString() =>
      'ReceiptInfo(open: $isOpen, total: $totalGross, usn: $uniqueSaleNumber)';
}

/// Printer mode for Command 149.
enum PrinterMode {
  /// Normal operation mode.
  normal(0),

  /// Programming mode.
  programming(1),

  /// Service mode.
  service(2),

  /// Fiscalization mode.
  fiscalization(3);

  final int code;
  const PrinterMode(this.code);
}

/// Diagnostic information (Command 90 response).
class DiagnosticInfo {
  /// Firmware version.
  final String firmwareVersion;

  /// Firmware date.
  final String firmwareDate;

  /// Device serial number.
  final String serialNumber;

  /// Fiscal memory serial number.
  final String fiscalMemorySerial;

  /// Total RAM in bytes.
  final int totalRam;

  /// Free RAM in bytes.
  final int freeRam;

  /// Printer model.
  final String model;

  /// Checksum.
  final String checksum;

  /// Codepage.
  final String codepage;

  /// Country code.
  final String countryCode;

  const DiagnosticInfo({
    this.firmwareVersion = '',
    this.firmwareDate = '',
    this.serialNumber = '',
    this.fiscalMemorySerial = '',
    this.totalRam = 0,
    this.freeRam = 0,
    this.model = '',
    this.checksum = '',
    this.codepage = '',
    this.countryCode = '',
  });

  /// Parse from command 90 response.
  factory DiagnosticInfo.fromResponse(String response) {
    final parts = response.split('\t');
    return DiagnosticInfo(
      firmwareVersion: parts.isNotEmpty ? parts[0] : '',
      firmwareDate: parts.length > 1 ? parts[1] : '',
      serialNumber: parts.length > 2 ? parts[2] : '',
      fiscalMemorySerial: parts.length > 3 ? parts[3] : '',
      totalRam: parts.length > 4 ? int.tryParse(parts[4]) ?? 0 : 0,
      freeRam: parts.length > 5 ? int.tryParse(parts[5]) ?? 0 : 0,
      model: parts.length > 6 ? parts[6] : '',
      checksum: parts.length > 7 ? parts[7] : '',
      codepage: parts.length > 8 ? parts[8] : '',
      countryCode: parts.length > 9 ? parts[9] : '',
    );
  }

  /// Percentage of RAM used.
  double get ramUsagePercent =>
      totalRam > 0 ? ((totalRam - freeRam) / totalRam) * 100 : 0.0;

  @override
  String toString() =>
      'DiagnosticInfo(model: $model, fw: $firmwareVersion, sn: $serialNumber)';
}
