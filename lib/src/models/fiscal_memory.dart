/// Fiscal memory models for Datecs SK1-21.
/// Based on FP_Protocol_EN.pdf - Commands 64, 68, 86, 89, 94, 95, 116.

/// Fiscal memory record (Z-report data).
class FiscalMemoryRecord {
  /// Z-report number (1-2500).
  final int zReportNumber;

  /// Date of the Z-report.
  final DateTime date;

  /// Total sales for tax group A.
  final double totalA;

  /// Total sales for tax group B.
  final double totalB;

  /// Total sales for tax group C.
  final double totalC;

  /// Total sales for tax group D.
  final double totalD;

  /// Total sales for tax groups E-H.
  final double totalEH;

  /// Grand total sales.
  final double grandTotal;

  /// Total VAT collected.
  final double totalVat;

  /// Number of receipts.
  final int receiptsCount;

  const FiscalMemoryRecord({
    required this.zReportNumber,
    required this.date,
    this.totalA = 0.0,
    this.totalB = 0.0,
    this.totalC = 0.0,
    this.totalD = 0.0,
    this.totalEH = 0.0,
    this.grandTotal = 0.0,
    this.totalVat = 0.0,
    this.receiptsCount = 0,
  });

  /// Parse from command 116 response.
  factory FiscalMemoryRecord.fromResponse(String response) {
    final parts = response.split('\t');
    DateTime? recordDate;
    if (parts.length > 1) {
      try {
        // Format: DD-MM-YY
        final dateParts = parts[1].split('-');
        if (dateParts.length == 3) {
          final day = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          var year = int.parse(dateParts[2]);
          if (year < 100) year += 2000;
          recordDate = DateTime(year, month, day);
        }
      } catch (_) {}
    }

    return FiscalMemoryRecord(
      zReportNumber: parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0,
      date: recordDate ?? DateTime.now(),
      totalA: parts.length > 2 ? double.tryParse(parts[2]) ?? 0.0 : 0.0,
      totalB: parts.length > 3 ? double.tryParse(parts[3]) ?? 0.0 : 0.0,
      totalC: parts.length > 4 ? double.tryParse(parts[4]) ?? 0.0 : 0.0,
      totalD: parts.length > 5 ? double.tryParse(parts[5]) ?? 0.0 : 0.0,
      totalEH: parts.length > 6 ? double.tryParse(parts[6]) ?? 0.0 : 0.0,
      grandTotal: parts.length > 7 ? double.tryParse(parts[7]) ?? 0.0 : 0.0,
      totalVat: parts.length > 8 ? double.tryParse(parts[8]) ?? 0.0 : 0.0,
      receiptsCount: parts.length > 9 ? int.tryParse(parts[9]) ?? 0 : 0,
    );
  }

  @override
  String toString() =>
      'FiscalMemoryRecord(Z#$zReportNumber, date: ${date.toIso8601String().substring(0, 10)}, total: $grandTotal)';
}

/// Last fiscal entry information (Command 64 response).
class LastFiscalEntryInfo {
  /// Last Z-report number.
  final int lastZReportNumber;

  /// Last Z-report date.
  final DateTime? lastZReportDate;

  /// Total receipts count since last Z.
  final int receiptsSinceLastZ;

  /// Sales total since last Z.
  final double salesTotalSinceLastZ;

  /// Date of last receipt.
  final DateTime? lastReceiptDate;

  /// Last receipt number.
  final int lastReceiptNumber;

  const LastFiscalEntryInfo({
    this.lastZReportNumber = 0,
    this.lastZReportDate,
    this.receiptsSinceLastZ = 0,
    this.salesTotalSinceLastZ = 0.0,
    this.lastReceiptDate,
    this.lastReceiptNumber = 0,
  });

  /// Parse from command 64 response.
  factory LastFiscalEntryInfo.fromResponse(String response) {
    final parts = response.split('\t');
    DateTime? zDate;
    DateTime? receiptDate;

    if (parts.length > 1 && parts[1].isNotEmpty) {
      zDate = _parseDate(parts[1]);
    }
    if (parts.length > 4 && parts[4].isNotEmpty) {
      receiptDate = _parseDate(parts[4]);
    }

    return LastFiscalEntryInfo(
      lastZReportNumber: parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0,
      lastZReportDate: zDate,
      receiptsSinceLastZ: parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0,
      salesTotalSinceLastZ:
          parts.length > 3 ? double.tryParse(parts[3]) ?? 0.0 : 0.0,
      lastReceiptDate: receiptDate,
      lastReceiptNumber: parts.length > 5 ? int.tryParse(parts[5]) ?? 0 : 0,
    );
  }

  static DateTime? _parseDate(String value) {
    try {
      // Format: DD-MM-YY
      final parts = value.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        var year = int.parse(parts[2]);
        if (year < 100) year += 2000;
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  @override
  String toString() =>
      'LastFiscalEntryInfo(lastZ: $lastZReportNumber, receiptsSinceZ: $receiptsSinceLastZ)';
}

/// Remaining Z-reports information (Command 68 response).
class RemainingZReportsInfo {
  /// Number of remaining Z-reports in fiscal memory.
  final int remainingZReports;

  /// Total capacity.
  final int totalCapacity;

  /// Used Z-reports.
  final int usedZReports;

  /// Percentage used.
  double get percentUsed =>
      totalCapacity > 0 ? (usedZReports / totalCapacity) * 100 : 0.0;

  const RemainingZReportsInfo({
    this.remainingZReports = 0,
    this.totalCapacity = 2500,
    this.usedZReports = 0,
  });

  /// Parse from command 68 response.
  factory RemainingZReportsInfo.fromResponse(String response) {
    final parts = response.split('\t');
    final remaining = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final total = parts.length > 1 ? int.tryParse(parts[1]) ?? 2500 : 2500;
    return RemainingZReportsInfo(
      remainingZReports: remaining,
      totalCapacity: total,
      usedZReports: total - remaining,
    );
  }

  @override
  String toString() =>
      'RemainingZReports($remainingZReports of $totalCapacity, ${percentUsed.toStringAsFixed(1)}% used)';
}

/// Fiscal memory test result (Command 89 response).
class FiscalMemoryTestResult {
  /// Is fiscal memory OK.
  final bool isOk;

  /// Error message if any.
  final String errorMessage;

  /// Number of records in FM.
  final int recordsCount;

  /// FM checksum.
  final String checksum;

  const FiscalMemoryTestResult({
    this.isOk = false,
    this.errorMessage = '',
    this.recordsCount = 0,
    this.checksum = '',
  });

  /// Parse from command 89 response.
  factory FiscalMemoryTestResult.fromResponse(String response) {
    final parts = response.split('\t');
    final statusCode = parts.isNotEmpty ? int.tryParse(parts[0]) ?? -1 : -1;
    return FiscalMemoryTestResult(
      isOk: statusCode == 0,
      errorMessage: statusCode != 0 && parts.length > 1 ? parts[1] : '',
      recordsCount: parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0,
      checksum: parts.length > 3 ? parts[3] : '',
    );
  }

  @override
  String toString() => 'FiscalMemoryTest(ok: $isOk, records: $recordsCount)';
}

/// Date of last fiscal record (Command 86 response).
class LastFiscalRecordDate {
  /// Date of the last fiscal record.
  final DateTime? date;

  /// Time of the last record.
  final DateTime? time;

  const LastFiscalRecordDate({
    this.date,
    this.time,
  });

  /// Parse from command 86 response.
  factory LastFiscalRecordDate.fromResponse(String response) {
    final parts = response.split('\t');
    DateTime? recordDate;
    DateTime? recordTime;

    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      try {
        final dateParts = parts[0].split('-');
        if (dateParts.length == 3) {
          final day = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          var year = int.parse(dateParts[2]);
          if (year < 100) year += 2000;
          recordDate = DateTime(year, month, day);
        }
      } catch (_) {}
    }

    if (parts.length > 1 && parts[1].isNotEmpty) {
      try {
        final timeParts = parts[1].split(':');
        if (timeParts.length >= 2) {
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          final second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;
          recordTime = DateTime(
            recordDate?.year ?? DateTime.now().year,
            recordDate?.month ?? 1,
            recordDate?.day ?? 1,
            hour,
            minute,
            second,
          );
        }
      } catch (_) {}
    }

    return LastFiscalRecordDate(
      date: recordDate,
      time: recordTime,
    );
  }

  @override
  String toString() =>
      'LastFiscalRecordDate(${date?.toIso8601String().substring(0, 10) ?? "none"})';
}

/// Fiscalization information.
class FiscalizationInfo {
  /// Tax number (CUI/CIF).
  final String taxNumber;

  /// Fiscal serial number.
  final String fiscalSerialNumber;

  /// Fiscalization date.
  final DateTime? fiscalizationDate;

  const FiscalizationInfo({
    this.taxNumber = '',
    this.fiscalSerialNumber = '',
    this.fiscalizationDate,
  });

  @override
  String toString() =>
      'FiscalizationInfo(tax: $taxNumber, serial: $fiscalSerialNumber)';
}
