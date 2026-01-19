import 'package:datecs_sk1_21/datecs_sk1_21.dart';
import 'package:test/test.dart';

void main() {
  group('PluItem', () {
    test('creates with required parameters', () {
      const item = PluItem(code: 1, name: 'Test Item', price: 10.0);

      expect(item.code, equals(1));
      expect(item.name, equals('Test Item'));
      expect(item.price, equals(10.0));
      expect(item.taxGroup, equals(TaxGroup.b));
      expect(item.department, equals(1));
      expect(item.itemGroup, equals(1));
      expect(item.isActive, isTrue);
      expect(item.isSingleItem, isFalse);
    });

    test('toCommandData generates correct format', () {
      const item = PluItem(
        code: 123,
        name: 'Coffee',
        price: 5.50,
        taxGroup: TaxGroup.b,
        barcode: '1234567890123',
      );

      final data = item.toCommandData();
      expect(data, startsWith('P\t'));
      expect(data, contains('123'));
      expect(data, contains('Coffee'));
      expect(data, contains('5.5'));
    });

    test('fromResponse parses tab-separated values', () {
      final item = PluItem.fromResponse(
        '100\tProduct Name\t25.50\t2\t1\t1\t0.0\t1234567890\tpcs\t1',
      );

      expect(item.code, equals(100));
      expect(item.name, equals('Product Name'));
      expect(item.price, equals(25.50));
      expect(item.taxGroup, equals(TaxGroup.b));
      expect(item.isActive, isTrue);
    });

    test('copyWith creates modified copy', () {
      const original = PluItem(code: 1, name: 'Original', price: 10.0);
      final modified = original.copyWith(name: 'Modified', price: 20.0);

      expect(modified.code, equals(1)); // Unchanged
      expect(modified.name, equals('Modified'));
      expect(modified.price, equals(20.0));
    });

    test('toString returns readable format', () {
      const item = PluItem(code: 1, name: 'Test', price: 10.0);
      final str = item.toString();

      expect(str, contains('code: 1'));
      expect(str, contains('Test'));
    });
  });

  group('PluSale', () {
    test('creates with required pluCode', () {
      const sale = PluSale(pluCode: 100);

      expect(sale.pluCode, equals(100));
      expect(sale.quantity, equals(1.0));
      expect(sale.discountType, equals(DiscountType.none));
      expect(sale.discountValue, equals(0.0));
    });

    test('toCommandData generates correct format', () {
      const sale = PluSale(pluCode: 50, quantity: 3.0);

      final data = sale.toCommandData();
      expect(data, contains('50'));
      expect(data, contains('3.0'));
    });

    test('toString returns readable format', () {
      const sale = PluSale(pluCode: 10, quantity: 2.0);
      expect(sale.toString(), contains('10'));
      expect(sale.toString(), contains('2.0'));
    });
  });

  group('PluReportItem', () {
    test('creates with required parameters', () {
      const item = PluReportItem(code: 1, name: 'Test');

      expect(item.code, equals(1));
      expect(item.name, equals('Test'));
      expect(item.quantitySold, equals(0.0));
      expect(item.totalAmount, equals(0.0));
      expect(item.lastSaleDate, isNull);
    });

    test('toString returns readable format', () {
      const item = PluReportItem(
        code: 1,
        name: 'Test',
        quantitySold: 10.0,
        totalAmount: 100.0,
      );

      final str = item.toString();
      expect(str, contains('1'));
      expect(str, contains('10.0'));
    });
  });
}
