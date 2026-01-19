/// Models for fiscal and non-fiscal receipt operations.

/// Receipt type.
enum ReceiptType {
  /// Standard fiscal receipt.
  fiscal(1),

  /// Fiscal invoice.
  fiscalInvoice(2),

  /// Airport fiscal receipt.
  airportFiscal(3),

  /// Non-fiscal receipt.
  nonFiscal(0);

  final int code;
  const ReceiptType(this.code);
}

/// Payment type.
enum PaymentType {
  /// Cash.
  cash(0),

  /// Bank card.
  card(1),

  /// Credit.
  credit(2),

  /// Meal tickets.
  mealTickets(3),

  /// Value tickets.
  valueTickets(4),

  /// Voucher.
  voucher(5),

  /// Modern payment (Google Pay, Apple Pay, etc).
  modernPayment(6),

  /// Card + cash advance.
  cardWithCashAdvance(7),

  /// Other methods.
  other(8),

  /// Currency.
  currency(9);

  final int code;
  const PaymentType(this.code);
}

/// Discount/surcharge type.
enum DiscountType {
  /// No discount.
  none(0),

  /// Percentage surcharge.
  surchargePercent(1),

  /// Percentage discount.
  discountPercent(2),

  /// Value surcharge.
  surchargeValue(3),

  /// Value discount.
  discountValue(4);

  final int code;
  const DiscountType(this.code);
}

/// VAT groups (tax groups).
enum TaxGroup {
  /// Group A - 0%.
  a(1, 0.0),

  /// Group B - 19%.
  b(2, 19.0),

  /// Group C - 9%.
  c(3, 9.0),

  /// Group D - 5%.
  d(4, 5.0),

  /// Group E.
  e(5, 0.0),

  /// Group F.
  f(6, 0.0),

  /// Group G.
  g(7, 0.0),

  /// Group H.
  h(8, 0.0);

  final int code;
  final double rate;
  const TaxGroup(this.code, this.rate);
}

/// Represents a sale item.
class SaleItem {
  /// Product name.
  final String name;

  /// VAT group.
  final TaxGroup taxGroup;

  /// Unit price.
  final double price;

  /// Quantity.
  final double quantity;

  /// Discount/surcharge type.
  final DiscountType discountType;

  /// Discount/surcharge value.
  final double discountValue;

  /// Department.
  final int department;

  /// Unit of measure.
  final String unit;

  const SaleItem({
    required this.name,
    this.taxGroup = TaxGroup.b,
    required this.price,
    this.quantity = 1.0,
    this.discountType = DiscountType.none,
    this.discountValue = 0.0,
    this.department = 1,
    this.unit = 'pcs',
  });

  /// Calculate total value of item.
  double get total {
    double baseTotal = price * quantity;
    switch (discountType) {
      case DiscountType.none:
        return baseTotal;
      case DiscountType.surchargePercent:
        return baseTotal * (1 + discountValue / 100);
      case DiscountType.discountPercent:
        return baseTotal * (1 - discountValue / 100);
      case DiscountType.surchargeValue:
        return baseTotal + discountValue;
      case DiscountType.discountValue:
        return baseTotal - discountValue;
    }
  }

  /// Generate data string for command 49.
  String toCommandData() {
    return '$name\t${taxGroup.code}\t$price\t$quantity\t${discountType.code}\t$discountValue\t$department\t$unit\t';
  }

  @override
  String toString() => 'SaleItem($name, $quantity x $price ${taxGroup.name})';
}

/// Represents a payment.
class Payment {
  /// Payment type.
  final PaymentType type;

  /// Amount paid (null for exact amount).
  final double? amount;

  const Payment({
    required this.type,
    this.amount,
  });

  /// Generate data string for command 53.
  String toCommandData() {
    final amountStr = amount?.toStringAsFixed(2) ?? '';
    return '${type.code}\t$amountStr\t';
  }

  @override
  String toString() => 'Payment(${type.name}, ${amount ?? "exact"})';
}

/// Operator information.
class OperatorInfo {
  /// Operator code.
  final String code;

  /// Operator password.
  final String password;

  /// Till number.
  final int tillNumber;

  const OperatorInfo({
    this.code = '1',
    this.password = '0001',
    this.tillNumber = 1,
  });

  @override
  String toString() => 'OperatorInfo(code: $code, till: $tillNumber)';
}
