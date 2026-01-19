import 'package:datecs_sk1_21/datecs_sk1_21.dart';
import 'package:test/test.dart';

void main() {
  group('Department', () {
    test('creates with required number', () {
      const dept = Department(number: 1);

      expect(dept.number, equals(1));
      expect(dept.name, isEmpty);
      expect(dept.taxGroup, equals(TaxGroup.b));
      expect(dept.totalSales, equals(0.0));
      expect(dept.isActive, isTrue);
    });

    test('netSales calculates correctly', () {
      const dept = Department(
        number: 1,
        totalSales: 1000,
        discountsTotal: 100,
        surchargesTotal: 50,
      );

      expect(dept.netSales, equals(950.0));
    });

    test('fromResponse parses tab-separated values', () {
      final dept = Department.fromResponse(
        1,
        'Electronics\t2\t9999.99\t5000.0\t250.0\t100\t50.0\t25.0\t1',
      );

      expect(dept.number, equals(1));
      expect(dept.name, equals('Electronics'));
      expect(dept.taxGroup, equals(TaxGroup.b));
      expect(dept.totalSales, equals(5000.0));
      expect(dept.isActive, isTrue);
    });

    test('toString contains key information', () {
      const dept = Department(number: 1, name: 'Test', totalSales: 500);
      final str = dept.toString();
      expect(str, contains('#1'));
      expect(str, contains('Test'));
    });
  });

  group('ItemGroup', () {
    test('creates with required number', () {
      const group = ItemGroup(number: 1);

      expect(group.number, equals(1));
      expect(group.name, isEmpty);
      expect(group.taxGroup, equals(TaxGroup.b));
      expect(group.totalSales, equals(0.0));
    });

    test('fromResponse parses tab-separated values', () {
      final group = ItemGroup.fromResponse(
        5,
        'Beverages\t2\t2500.0\t500.0\t200\t50',
      );

      expect(group.number, equals(5));
      expect(group.name, equals('Beverages'));
      expect(group.totalSales, equals(2500.0));
      expect(group.itemsCount, equals(50));
    });

    test('toString contains key information', () {
      const group = ItemGroup(number: 1, name: 'Test', itemsCount: 10);
      final str = group.toString();
      expect(str, contains('#1'));
      expect(str, contains('Test'));
    });
  });

  group('DailyTaxInfo', () {
    test('creates with default values', () {
      const info = DailyTaxInfo();

      expect(info.grandTotal, equals(0.0));
      expect(info.grandTotalVat, equals(0.0));
      expect(info.fiscalReceiptsCount, equals(0));
    });

    test('toString contains key information', () {
      const info = DailyTaxInfo(
        grandTotal: 1000,
        grandTotalVat: 190,
        fiscalReceiptsCount: 50,
      );

      final str = info.toString();
      expect(str, contains('1000'));
      expect(str, contains('50'));
    });
  });

  group('AdditionalDailyInfo', () {
    test('creates with default values', () {
      const info = AdditionalDailyInfo();

      expect(info.cashInDrawer, equals(0.0));
      expect(info.totalCashIn, equals(0.0));
      expect(info.totalCashOut, equals(0.0));
      expect(info.cashInCount, equals(0));
      expect(info.cashOutCount, equals(0));
    });

    test('fromResponse parses tab-separated values', () {
      final info = AdditionalDailyInfo.fromResponse(
        '500.0\t1000.0\t200.0\t5\t2\t800.0\t400.0',
      );

      expect(info.cashInDrawer, equals(500.0));
      expect(info.totalCashIn, equals(1000.0));
      expect(info.totalCashOut, equals(200.0));
      expect(info.cashInCount, equals(5));
      expect(info.cashOutCount, equals(2));
    });

    test('toString contains key information', () {
      const info = AdditionalDailyInfo(
        cashInDrawer: 500,
        totalCashIn: 1000,
        totalCashOut: 200,
      );

      final str = info.toString();
      expect(str, contains('500'));
      expect(str, contains('1000'));
    });
  });
}
