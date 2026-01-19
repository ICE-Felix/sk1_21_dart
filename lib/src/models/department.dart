/// Department and item group models for Datecs SK1-21.
/// Based on FP_Protocol_EN.pdf - Commands 87, 88.

import 'receipt.dart';

/// Department information and statistics.
class Department {
  /// Department number (1-99).
  final int number;

  /// Department name.
  final String name;

  /// Default tax group for the department.
  final TaxGroup taxGroup;

  /// Price limit for items in this department.
  final double priceLimit;

  /// Total sales amount.
  final double totalSales;

  /// Total quantity sold.
  final double totalQuantity;

  /// Number of sales transactions.
  final int salesCount;

  /// Total discounts.
  final double discountsTotal;

  /// Total surcharges.
  final double surchargesTotal;

  /// Is department active.
  final bool isActive;

  const Department({
    required this.number,
    this.name = '',
    this.taxGroup = TaxGroup.b,
    this.priceLimit = 999999.99,
    this.totalSales = 0.0,
    this.totalQuantity = 0.0,
    this.salesCount = 0,
    this.discountsTotal = 0.0,
    this.surchargesTotal = 0.0,
    this.isActive = true,
  });

  /// Parse from command 88 response.
  factory Department.fromResponse(int deptNumber, String response) {
    final parts = response.split('\t');
    return Department(
      number: deptNumber,
      name: parts.isNotEmpty ? parts[0] : '',
      taxGroup: parts.length > 1 ? _parseTaxGroup(parts[1]) : TaxGroup.b,
      priceLimit:
          parts.length > 2 ? double.tryParse(parts[2]) ?? 999999.99 : 999999.99,
      totalSales: parts.length > 3 ? double.tryParse(parts[3]) ?? 0.0 : 0.0,
      totalQuantity: parts.length > 4 ? double.tryParse(parts[4]) ?? 0.0 : 0.0,
      salesCount: parts.length > 5 ? int.tryParse(parts[5]) ?? 0 : 0,
      discountsTotal: parts.length > 6 ? double.tryParse(parts[6]) ?? 0.0 : 0.0,
      surchargesTotal:
          parts.length > 7 ? double.tryParse(parts[7]) ?? 0.0 : 0.0,
      isActive: parts.length > 8 ? parts[8] == '1' : true,
    );
  }

  static TaxGroup _parseTaxGroup(String value) {
    final code = int.tryParse(value) ?? 2;
    for (final group in TaxGroup.values) {
      if (group.code == code) return group;
    }
    return TaxGroup.b;
  }

  /// Net sales (sales - discounts + surcharges).
  double get netSales => totalSales - discountsTotal + surchargesTotal;

  @override
  String toString() => 'Department(#$number: $name, sales: $totalSales)';
}

/// Item group information and statistics.
class ItemGroup {
  /// Group number (1-99).
  final int number;

  /// Group name.
  final String name;

  /// Default tax group.
  final TaxGroup taxGroup;

  /// Total sales amount.
  final double totalSales;

  /// Total quantity sold.
  final double totalQuantity;

  /// Number of sales transactions.
  final int salesCount;

  /// Number of items in this group.
  final int itemsCount;

  const ItemGroup({
    required this.number,
    this.name = '',
    this.taxGroup = TaxGroup.b,
    this.totalSales = 0.0,
    this.totalQuantity = 0.0,
    this.salesCount = 0,
    this.itemsCount = 0,
  });

  /// Parse from command 87 response.
  factory ItemGroup.fromResponse(int groupNumber, String response) {
    final parts = response.split('\t');
    return ItemGroup(
      number: groupNumber,
      name: parts.isNotEmpty ? parts[0] : '',
      taxGroup: parts.length > 1 ? _parseTaxGroup(parts[1]) : TaxGroup.b,
      totalSales: parts.length > 2 ? double.tryParse(parts[2]) ?? 0.0 : 0.0,
      totalQuantity: parts.length > 3 ? double.tryParse(parts[3]) ?? 0.0 : 0.0,
      salesCount: parts.length > 4 ? int.tryParse(parts[4]) ?? 0 : 0,
      itemsCount: parts.length > 5 ? int.tryParse(parts[5]) ?? 0 : 0,
    );
  }

  static TaxGroup _parseTaxGroup(String value) {
    final code = int.tryParse(value) ?? 2;
    for (final group in TaxGroup.values) {
      if (group.code == code) return group;
    }
    return TaxGroup.b;
  }

  @override
  String toString() =>
      'ItemGroup(#$number: $name, sales: $totalSales, items: $itemsCount)';
}

/// Daily taxation information (Command 65 response).
class DailyTaxInfo {
  /// Total sales by tax group.
  final Map<TaxGroup, double> salesByTaxGroup;

  /// Total VAT by tax group.
  final Map<TaxGroup, double> vatByTaxGroup;

  /// Grand total sales.
  final double grandTotal;

  /// Grand total VAT.
  final double grandTotalVat;

  /// Number of fiscal receipts.
  final int fiscalReceiptsCount;

  /// Number of cancelled receipts.
  final int cancelledReceiptsCount;

  const DailyTaxInfo({
    this.salesByTaxGroup = const {},
    this.vatByTaxGroup = const {},
    this.grandTotal = 0.0,
    this.grandTotalVat = 0.0,
    this.fiscalReceiptsCount = 0,
    this.cancelledReceiptsCount = 0,
  });

  /// Parse from command 65 response.
  factory DailyTaxInfo.fromResponse(String response) {
    final parts = response.split('\t');
    final salesMap = <TaxGroup, double>{};
    final vatMap = <TaxGroup, double>{};

    // Parse sales by tax group (A, B, C, D, E, F, G, H)
    for (var i = 0; i < 8 && i * 2 < parts.length; i++) {
      final taxGroup = TaxGroup.values[i];
      salesMap[taxGroup] = double.tryParse(parts[i * 2]) ?? 0.0;
      if (i * 2 + 1 < parts.length) {
        vatMap[taxGroup] = double.tryParse(parts[i * 2 + 1]) ?? 0.0;
      }
    }

    return DailyTaxInfo(
      salesByTaxGroup: salesMap,
      vatByTaxGroup: vatMap,
      grandTotal: salesMap.values.fold(0.0, (sum, v) => sum + v),
      grandTotalVat: vatMap.values.fold(0.0, (sum, v) => sum + v),
      fiscalReceiptsCount: parts.length > 16 ? int.tryParse(parts[16]) ?? 0 : 0,
      cancelledReceiptsCount:
          parts.length > 17 ? int.tryParse(parts[17]) ?? 0 : 0,
    );
  }

  @override
  String toString() =>
      'DailyTaxInfo(total: $grandTotal, vat: $grandTotalVat, receipts: $fiscalReceiptsCount)';
}

/// Additional daily information (Command 110 response).
class AdditionalDailyInfo {
  /// Cash in drawer.
  final double cashInDrawer;

  /// Total cash in operations.
  final double totalCashIn;

  /// Total cash out operations.
  final double totalCashOut;

  /// Number of cash in operations.
  final int cashInCount;

  /// Number of cash out operations.
  final int cashOutCount;

  /// Total payments by type.
  final Map<int, double> paymentsByType;

  const AdditionalDailyInfo({
    this.cashInDrawer = 0.0,
    this.totalCashIn = 0.0,
    this.totalCashOut = 0.0,
    this.cashInCount = 0,
    this.cashOutCount = 0,
    this.paymentsByType = const {},
  });

  /// Parse from command 110 response.
  factory AdditionalDailyInfo.fromResponse(String response) {
    final parts = response.split('\t');
    final payments = <int, double>{};

    // Parse payment types (index 5 onwards)
    for (var i = 5; i < parts.length && i < 15; i++) {
      payments[i - 5] = double.tryParse(parts[i]) ?? 0.0;
    }

    return AdditionalDailyInfo(
      cashInDrawer: parts.isNotEmpty ? double.tryParse(parts[0]) ?? 0.0 : 0.0,
      totalCashIn: parts.length > 1 ? double.tryParse(parts[1]) ?? 0.0 : 0.0,
      totalCashOut: parts.length > 2 ? double.tryParse(parts[2]) ?? 0.0 : 0.0,
      cashInCount: parts.length > 3 ? int.tryParse(parts[3]) ?? 0 : 0,
      cashOutCount: parts.length > 4 ? int.tryParse(parts[4]) ?? 0 : 0,
      paymentsByType: payments,
    );
  }

  @override
  String toString() =>
      'AdditionalDailyInfo(cash: $cashInDrawer, in: $totalCashIn, out: $totalCashOut)';
}
