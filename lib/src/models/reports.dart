/// Models for Datecs reports.

/// Daily report type.
enum DailyReportType {
  /// X report - preview (does not close the day).
  xReport('X'),

  /// Z report - daily closure (writes to fiscal memory).
  zReport('Z'),

  /// ECR report.
  ecrReport('E'),

  /// Departments report.
  departmentsReport('D'),

  /// Item groups report.
  itemGroupsReport('G');

  final String code;
  const DailyReportType(this.code);
}

/// Result of a Z or X report.
class DailyReportResult {
  /// Z report number (1-2500).
  final int reportNumber;

  /// Total VAT group A.
  final double totalA;

  /// Total VAT group B.
  final double totalB;

  /// Total VAT group C.
  final double totalC;

  /// Total VAT group D.
  final double totalD;

  /// Total VAT group E.
  final double totalE;

  /// Total VAT group F.
  final double totalF;

  /// Total EXEMPT.
  final double totalExempt;

  /// Total simplified invoices.
  final double totalSimplifiedInvoice;

  /// VAT simplified invoices.
  final double vatSimplifiedInvoice;

  const DailyReportResult({
    required this.reportNumber,
    this.totalA = 0.0,
    this.totalB = 0.0,
    this.totalC = 0.0,
    this.totalD = 0.0,
    this.totalE = 0.0,
    this.totalF = 0.0,
    this.totalExempt = 0.0,
    this.totalSimplifiedInvoice = 0.0,
    this.vatSimplifiedInvoice = 0.0,
  });

  /// Calculate grand total.
  double get grandTotal =>
      totalA + totalB + totalC + totalD + totalE + totalF + totalExempt;

  @override
  String toString() => '''DailyReportResult(
  reportNumber: $reportNumber,
  grandTotal: $grandTotal,
  totalA: $totalA, totalB: $totalB, totalC: $totalC, totalD: $totalD
)''';
}
