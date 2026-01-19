/// PLU (Price Look-Up) item models for Datecs SK1-21.
/// Based on FP_Protocol_EN.pdf - Command 107 and Command 58.

import 'receipt.dart';

/// A programmed PLU (Price Look-Up) item in the printer's memory.
class PluItem {
  /// PLU code (unique identifier).
  final int code;

  /// Item name/description.
  final String name;

  /// Unit price.
  final double price;

  /// Tax group (A-H).
  final TaxGroup taxGroup;

  /// Department number (1-99).
  final int department;

  /// Item group number (1-99).
  final int itemGroup;

  /// Current stock quantity.
  final double stockQuantity;

  /// Barcode (EAN13, EAN8, etc).
  final String barcode;

  /// Unit of measurement.
  final String unit;

  /// Is the item active/enabled.
  final bool isActive;

  /// Single item flag (quantity always 1).
  final bool isSingleItem;

  const PluItem({
    required this.code,
    required this.name,
    required this.price,
    this.taxGroup = TaxGroup.b,
    this.department = 1,
    this.itemGroup = 1,
    this.stockQuantity = 0.0,
    this.barcode = '',
    this.unit = 'pcs',
    this.isActive = true,
    this.isSingleItem = false,
  });

  /// Generate command data for programming (Command 107).
  String toCommandData() {
    // Format: PLU\t<code>\t<name>\t<price>\t<taxGr>\t<dept>\t<group>\t<qty>\t<barcode>\t<unit>\t<flags>\t
    final flags = (isActive ? 1 : 0) | (isSingleItem ? 2 : 0);
    return 'P\t$code\t$name\t$price\t${taxGroup.code}\t$department\t$itemGroup\t$stockQuantity\t$barcode\t$unit\t$flags\t';
  }

  /// Parse from command 107 read response.
  factory PluItem.fromResponse(String response) {
    final parts = response.split('\t');
    return PluItem(
      code: parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0,
      name: parts.length > 1 ? parts[1] : '',
      price: parts.length > 2 ? double.tryParse(parts[2]) ?? 0.0 : 0.0,
      taxGroup: parts.length > 3 ? _parseTaxGroup(parts[3]) : TaxGroup.b,
      department: parts.length > 4 ? int.tryParse(parts[4]) ?? 1 : 1,
      itemGroup: parts.length > 5 ? int.tryParse(parts[5]) ?? 1 : 1,
      stockQuantity: parts.length > 6 ? double.tryParse(parts[6]) ?? 0.0 : 0.0,
      barcode: parts.length > 7 ? parts[7] : '',
      unit: parts.length > 8 ? parts[8] : 'pcs',
      isActive:
          parts.length > 9 ? (int.tryParse(parts[9]) ?? 0) & 1 != 0 : true,
      isSingleItem:
          parts.length > 9 ? (int.tryParse(parts[9]) ?? 0) & 2 != 0 : false,
    );
  }

  static TaxGroup _parseTaxGroup(String value) {
    final code = int.tryParse(value) ?? 2;
    for (final group in TaxGroup.values) {
      if (group.code == code) return group;
    }
    return TaxGroup.b;
  }

  /// Create a copy with modified fields.
  PluItem copyWith({
    int? code,
    String? name,
    double? price,
    TaxGroup? taxGroup,
    int? department,
    int? itemGroup,
    double? stockQuantity,
    String? barcode,
    String? unit,
    bool? isActive,
    bool? isSingleItem,
  }) {
    return PluItem(
      code: code ?? this.code,
      name: name ?? this.name,
      price: price ?? this.price,
      taxGroup: taxGroup ?? this.taxGroup,
      department: department ?? this.department,
      itemGroup: itemGroup ?? this.itemGroup,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      barcode: barcode ?? this.barcode,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      isSingleItem: isSingleItem ?? this.isSingleItem,
    );
  }

  @override
  String toString() =>
      'PluItem(code: $code, name: $name, price: $price, tax: ${taxGroup.name})';
}

/// Sale of a programmed PLU item (Command 58).
class PluSale {
  /// PLU code to sell.
  final int pluCode;

  /// Quantity to sell.
  final double quantity;

  /// Discount type (optional).
  final DiscountType discountType;

  /// Discount value (optional).
  final double discountValue;

  const PluSale({
    required this.pluCode,
    this.quantity = 1.0,
    this.discountType = DiscountType.none,
    this.discountValue = 0.0,
  });

  /// Generate command data for sale (Command 58).
  String toCommandData() {
    return '$pluCode\t$quantity\t${discountType.code}\t$discountValue\t';
  }

  @override
  String toString() => 'PluSale(code: $pluCode, qty: $quantity)';
}

/// PLU report item (from Command 111 report).
class PluReportItem {
  /// PLU code.
  final int code;

  /// Item name.
  final String name;

  /// Total quantity sold.
  final double quantitySold;

  /// Total amount.
  final double totalAmount;

  /// Last sale date.
  final DateTime? lastSaleDate;

  const PluReportItem({
    required this.code,
    required this.name,
    this.quantitySold = 0.0,
    this.totalAmount = 0.0,
    this.lastSaleDate,
  });

  @override
  String toString() =>
      'PluReportItem(code: $code, sold: $quantitySold, total: $totalAmount)';
}
