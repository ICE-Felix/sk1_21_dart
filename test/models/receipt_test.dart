import 'package:datecs_sk1_21/datecs_sk1_21.dart';
import 'package:test/test.dart';

void main() {
  group('SaleItem', () {
    test('creates with required parameters', () {
      const item = SaleItem(name: 'Test Product', price: 10.0);

      expect(item.name, equals('Test Product'));
      expect(item.price, equals(10.0));
      expect(item.quantity, equals(1.0));
      expect(item.taxGroup, equals(TaxGroup.b));
      expect(item.discountType, equals(DiscountType.none));
      expect(item.discountValue, equals(0.0));
      expect(item.department, equals(1));
      expect(item.unit, equals('pcs'));
    });

    test('calculates total without discount', () {
      const item = SaleItem(name: 'Product', price: 10.0, quantity: 2.0);

      expect(item.total, equals(20.0));
    });

    test('calculates total with percentage discount', () {
      const item = SaleItem(
        name: 'Product',
        price: 100.0,
        quantity: 1.0,
        discountType: DiscountType.discountPercent,
        discountValue: 10.0,
      );

      expect(item.total, equals(90.0));
    });

    test('calculates total with percentage surcharge', () {
      const item = SaleItem(
        name: 'Product',
        price: 100.0,
        quantity: 1.0,
        discountType: DiscountType.surchargePercent,
        discountValue: 10.0,
      );

      expect(item.total, closeTo(110.0, 0.001));
    });

    test('calculates total with value discount', () {
      const item = SaleItem(
        name: 'Product',
        price: 100.0,
        quantity: 1.0,
        discountType: DiscountType.discountValue,
        discountValue: 15.0,
      );

      expect(item.total, equals(85.0));
    });

    test('calculates total with value surcharge', () {
      const item = SaleItem(
        name: 'Product',
        price: 100.0,
        quantity: 1.0,
        discountType: DiscountType.surchargeValue,
        discountValue: 15.0,
      );

      expect(item.total, equals(115.0));
    });

    test('toCommandData generates correct format', () {
      const item = SaleItem(
        name: 'Test',
        price: 10.5,
        quantity: 2.0,
        taxGroup: TaxGroup.b,
        department: 1,
        unit: 'pcs',
      );

      final data = item.toCommandData();
      expect(data, contains('Test'));
      expect(data, contains('10.5'));
      expect(data, contains('2.0'));
    });

    test('toString returns readable format', () {
      const item = SaleItem(name: 'Product', price: 10.0, quantity: 2.0);

      expect(item.toString(), contains('Product'));
      expect(item.toString(), contains('10.0'));
    });
  });

  group('Payment', () {
    test('creates with required type', () {
      const payment = Payment(type: PaymentType.cash);

      expect(payment.type, equals(PaymentType.cash));
      expect(payment.amount, isNull);
    });

    test('creates with specific amount', () {
      const payment = Payment(type: PaymentType.card, amount: 50.0);

      expect(payment.type, equals(PaymentType.card));
      expect(payment.amount, equals(50.0));
    });

    test('toCommandData generates correct format for exact amount', () {
      const payment = Payment(type: PaymentType.cash);

      final data = payment.toCommandData();
      expect(data, startsWith('0\t'));
    });

    test('toCommandData includes amount when specified', () {
      const payment = Payment(type: PaymentType.card, amount: 100.0);

      final data = payment.toCommandData();
      expect(data, contains('100.00'));
    });

    test('toString returns readable format', () {
      const payment = Payment(type: PaymentType.cash);
      expect(payment.toString(), contains('cash'));
    });
  });

  group('OperatorInfo', () {
    test('creates with default values', () {
      const operator = OperatorInfo();

      expect(operator.code, equals('1'));
      expect(operator.password, equals('0001'));
      expect(operator.tillNumber, equals(1));
    });

    test('creates with custom values', () {
      const operator = OperatorInfo(
        code: '5',
        password: '1234',
        tillNumber: 2,
      );

      expect(operator.code, equals('5'));
      expect(operator.password, equals('1234'));
      expect(operator.tillNumber, equals(2));
    });
  });

  group('TaxGroup', () {
    test('has correct codes', () {
      expect(TaxGroup.a.code, equals(1));
      expect(TaxGroup.b.code, equals(2));
      expect(TaxGroup.c.code, equals(3));
      expect(TaxGroup.d.code, equals(4));
    });

    test('has correct default rates', () {
      expect(TaxGroup.a.rate, equals(0.0));
      expect(TaxGroup.b.rate, equals(19.0));
      expect(TaxGroup.c.rate, equals(9.0));
      expect(TaxGroup.d.rate, equals(5.0));
    });
  });

  group('PaymentType', () {
    test('has correct codes', () {
      expect(PaymentType.cash.code, equals(0));
      expect(PaymentType.card.code, equals(1));
      expect(PaymentType.credit.code, equals(2));
      expect(PaymentType.mealTickets.code, equals(3));
    });

    test('has all 10 payment types', () {
      expect(PaymentType.values.length, equals(10));
    });
  });

  group('DiscountType', () {
    test('has correct codes', () {
      expect(DiscountType.none.code, equals(0));
      expect(DiscountType.surchargePercent.code, equals(1));
      expect(DiscountType.discountPercent.code, equals(2));
      expect(DiscountType.surchargeValue.code, equals(3));
      expect(DiscountType.discountValue.code, equals(4));
    });
  });

  group('ReceiptType', () {
    test('has correct codes', () {
      expect(ReceiptType.fiscal.code, equals(1));
      expect(ReceiptType.fiscalInvoice.code, equals(2));
      expect(ReceiptType.airportFiscal.code, equals(3));
      expect(ReceiptType.nonFiscal.code, equals(0));
    });
  });
}
