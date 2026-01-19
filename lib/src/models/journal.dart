/// Electronic journal models for Datecs SK1-21.
/// Based on FP_Protocol_EN.pdf - Commands 124, 125, 128.

/// Electronic journal information (Command 125 response).
class JournalInfo {
  /// Total records in journal.
  final int totalRecords;

  /// First record number.
  final int firstRecordNumber;

  /// Last record number.
  final int lastRecordNumber;

  /// First record date.
  final DateTime? firstRecordDate;

  /// Last record date.
  final DateTime? lastRecordDate;

  /// Used space in KB.
  final int usedSpaceKb;

  /// Total space in KB.
  final int totalSpaceKb;

  /// Percentage used.
  double get percentUsed =>
      totalSpaceKb > 0 ? (usedSpaceKb / totalSpaceKb) * 100 : 0.0;

  const JournalInfo({
    this.totalRecords = 0,
    this.firstRecordNumber = 0,
    this.lastRecordNumber = 0,
    this.firstRecordDate,
    this.lastRecordDate,
    this.usedSpaceKb = 0,
    this.totalSpaceKb = 0,
  });

  /// Parse from command 125 response.
  factory JournalInfo.fromResponse(String response) {
    final parts = response.split('\t');
    return JournalInfo(
      totalRecords: parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0,
      firstRecordNumber: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      lastRecordNumber: parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0,
      firstRecordDate: parts.length > 3 ? _parseDate(parts[3]) : null,
      lastRecordDate: parts.length > 4 ? _parseDate(parts[4]) : null,
      usedSpaceKb: parts.length > 5 ? int.tryParse(parts[5]) ?? 0 : 0,
      totalSpaceKb: parts.length > 6 ? int.tryParse(parts[6]) ?? 0 : 0,
    );
  }

  static DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;
    try {
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
      'JournalInfo(records: $totalRecords, used: ${percentUsed.toStringAsFixed(1)}%)';
}

/// Journal search result (Command 124 response).
class JournalSearchResult {
  /// Found record number.
  final int recordNumber;

  /// Record date.
  final DateTime? date;

  /// Record type.
  final JournalRecordType type;

  /// Receipt number (if applicable).
  final int? receiptNumber;

  /// Z-report number (if applicable).
  final int? zReportNumber;

  const JournalSearchResult({
    this.recordNumber = 0,
    this.date,
    this.type = JournalRecordType.unknown,
    this.receiptNumber,
    this.zReportNumber,
  });

  /// Parse from command 124 response.
  factory JournalSearchResult.fromResponse(String response) {
    final parts = response.split('\t');
    return JournalSearchResult(
      recordNumber: parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0,
      date: parts.length > 1 ? _parseDateTime(parts[1]) : null,
      type: parts.length > 2
          ? JournalRecordType.fromCode(parts[2])
          : JournalRecordType.unknown,
      receiptNumber: parts.length > 3 ? int.tryParse(parts[3]) : null,
      zReportNumber: parts.length > 4 ? int.tryParse(parts[4]) : null,
    );
  }

  static DateTime? _parseDateTime(String value) {
    if (value.isEmpty) return null;
    try {
      // Format: DD-MM-YY HH:MM:SS
      final dateTime = value.split(' ');
      final dateParts = dateTime[0].split('-');
      if (dateParts.length == 3) {
        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        var year = int.parse(dateParts[2]);
        if (year < 100) year += 2000;

        if (dateTime.length > 1) {
          final timeParts = dateTime[1].split(':');
          if (timeParts.length >= 2) {
            return DateTime(
              year,
              month,
              day,
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
              timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
            );
          }
        }
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  @override
  String toString() =>
      'JournalSearchResult(record: $recordNumber, type: ${type.name})';
}

/// Type of journal record.
enum JournalRecordType {
  /// Unknown record type.
  unknown('U', 'Unknown'),

  /// Fiscal receipt.
  fiscalReceipt('F', 'Fiscal receipt'),

  /// Non-fiscal receipt.
  nonFiscalReceipt('N', 'Non-fiscal receipt'),

  /// Z-report.
  zReport('Z', 'Z-Report'),

  /// X-report.
  xReport('X', 'X-Report'),

  /// Cash in operation.
  cashIn('I', 'Cash in'),

  /// Cash out operation.
  cashOut('O', 'Cash out'),

  /// Cancelled receipt.
  cancelled('C', 'Cancelled receipt'),

  /// Service operation.
  service('S', 'Service');

  final String code;
  final String description;
  const JournalRecordType(this.code, this.description);

  /// Parse from code string.
  static JournalRecordType fromCode(String code) {
    for (final type in JournalRecordType.values) {
      if (type.code == code) return type;
    }
    return JournalRecordType.unknown;
  }
}

/// XML export configuration.
class XmlExportConfig {
  /// Export path.
  final String path;

  /// Start date.
  final DateTime? startDate;

  /// End date.
  final DateTime? endDate;

  /// Start Z-report number.
  final int? startZNumber;

  /// End Z-report number.
  final int? endZNumber;

  /// Include receipt details.
  final bool includeDetails;

  const XmlExportConfig({
    required this.path,
    this.startDate,
    this.endDate,
    this.startZNumber,
    this.endZNumber,
    this.includeDetails = true,
  });

  /// Generate command data for export (Command 128).
  String toCommandData() {
    final parts = <String>[];
    parts.add(path);

    if (startDate != null) {
      parts.add(_formatDate(startDate!));
    } else if (startZNumber != null) {
      parts.add('Z$startZNumber');
    }

    if (endDate != null) {
      parts.add(_formatDate(endDate!));
    } else if (endZNumber != null) {
      parts.add('Z$endZNumber');
    }

    parts.add(includeDetails ? '1' : '0');

    return parts.join('\t') + '\t';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${(date.year % 100).toString().padLeft(2, '0')}';
  }
}

/// XML export result.
class XmlExportResult {
  /// Export was successful.
  final bool success;

  /// Path to exported file.
  final String filePath;

  /// Number of records exported.
  final int recordsExported;

  /// Error message if failed.
  final String errorMessage;

  const XmlExportResult({
    this.success = false,
    this.filePath = '',
    this.recordsExported = 0,
    this.errorMessage = '',
  });

  @override
  String toString() =>
      'XmlExportResult(success: $success, records: $recordsExported, path: $filePath)';
}
