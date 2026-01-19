/// Operator data models for Datecs SK1-21.
/// Based on FP_Protocol_EN.pdf - Commands 101, 105, 112.

/// Extended operator information with sales statistics.
class OperatorData {
  /// Operator number (1-30).
  final int number;

  /// Operator name.
  final String name;

  /// Operator password.
  final String password;

  /// Total sales amount.
  final double salesTotal;

  /// Total number of receipts.
  final int receiptsCount;

  /// Total discounts given.
  final double discountsTotal;

  /// Total surcharges applied.
  final double surchargesTotal;

  /// Total VAT collected.
  final double vatTotal;

  /// Number of voided receipts.
  final int voidedReceipts;

  /// Last sale date/time.
  final DateTime? lastSaleDate;

  const OperatorData({
    required this.number,
    this.name = '',
    this.password = '',
    this.salesTotal = 0.0,
    this.receiptsCount = 0,
    this.discountsTotal = 0.0,
    this.surchargesTotal = 0.0,
    this.vatTotal = 0.0,
    this.voidedReceipts = 0,
    this.lastSaleDate,
  });

  /// Parse from command 112 response.
  factory OperatorData.fromResponse(int operatorNumber, String response) {
    final parts = response.split('\t');
    DateTime? lastDate;
    if (parts.length > 8 && parts[8].isNotEmpty) {
      try {
        lastDate = DateTime.parse(parts[8]);
      } catch (_) {}
    }

    return OperatorData(
      number: operatorNumber,
      name: parts.isNotEmpty ? parts[0] : '',
      salesTotal: parts.length > 1 ? double.tryParse(parts[1]) ?? 0.0 : 0.0,
      receiptsCount: parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0,
      discountsTotal: parts.length > 3 ? double.tryParse(parts[3]) ?? 0.0 : 0.0,
      surchargesTotal:
          parts.length > 4 ? double.tryParse(parts[4]) ?? 0.0 : 0.0,
      vatTotal: parts.length > 5 ? double.tryParse(parts[5]) ?? 0.0 : 0.0,
      voidedReceipts: parts.length > 6 ? int.tryParse(parts[6]) ?? 0 : 0,
      password: parts.length > 7 ? parts[7] : '',
      lastSaleDate: lastDate,
    );
  }

  /// Net sales (total - discounts + surcharges).
  double get netSales => salesTotal - discountsTotal + surchargesTotal;

  /// Average receipt value.
  double get averageReceipt =>
      receiptsCount > 0 ? salesTotal / receiptsCount : 0.0;

  @override
  String toString() =>
      'OperatorData(#$number: $name, sales: $salesTotal, receipts: $receiptsCount)';
}

/// Operator password change request.
class OperatorPasswordChange {
  /// Operator number (1-30).
  final int operatorNumber;

  /// Current password.
  final String oldPassword;

  /// New password.
  final String newPassword;

  const OperatorPasswordChange({
    required this.operatorNumber,
    required this.oldPassword,
    required this.newPassword,
  });

  /// Generate command data for password change (Command 101).
  String toCommandData() {
    return '$operatorNumber\t$oldPassword\t$newPassword\t';
  }
}

/// Operators report summary (Command 105).
class OperatorsReportSummary {
  /// List of operator statistics.
  final List<OperatorData> operators;

  /// Grand total sales.
  final double grandTotal;

  /// Total receipts count.
  final int totalReceipts;

  const OperatorsReportSummary({
    this.operators = const [],
    this.grandTotal = 0.0,
    this.totalReceipts = 0,
  });

  @override
  String toString() =>
      'OperatorsReport(operators: ${operators.length}, total: $grandTotal)';
}
