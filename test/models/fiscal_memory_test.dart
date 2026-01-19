import 'package:datecs_sk1_21/datecs_sk1_21.dart';
import 'package:test/test.dart';

void main() {
  group('FiscalMemoryRecord', () {
    test('creates with required parameters', () {
      final record = FiscalMemoryRecord(
        zReportNumber: 100,
        date: DateTime(2024, 1, 15),
      );

      expect(record.zReportNumber, equals(100));
      expect(record.date.year, equals(2024));
      expect(record.grandTotal, equals(0.0));
    });

    test('fromResponse parses tab-separated values', () {
      final record = FiscalMemoryRecord.fromResponse(
        '50\t15-01-24\t100.0\t200.0\t50.0\t25.0\t10.0\t385.0\t73.15\t25',
      );

      expect(record.zReportNumber, equals(50));
      expect(record.date.day, equals(15));
      expect(record.date.month, equals(1));
      expect(record.totalA, equals(100.0));
      expect(record.totalB, equals(200.0));
      expect(record.grandTotal, equals(385.0));
      expect(record.receiptsCount, equals(25));
    });

    test('toString contains key information', () {
      final record = FiscalMemoryRecord(
        zReportNumber: 100,
        date: DateTime(2024, 1, 15),
        grandTotal: 500.0,
      );

      final str = record.toString();
      expect(str, contains('100'));
      expect(str, contains('500.0'));
    });
  });

  group('LastFiscalEntryInfo', () {
    test('creates with default values', () {
      const info = LastFiscalEntryInfo();

      expect(info.lastZReportNumber, equals(0));
      expect(info.lastZReportDate, isNull);
      expect(info.receiptsSinceLastZ, equals(0));
    });

    test('fromResponse parses tab-separated values', () {
      final info = LastFiscalEntryInfo.fromResponse(
        '50\t15-01-24\t10\t250.50\t16-01-24\t1234',
      );

      expect(info.lastZReportNumber, equals(50));
      expect(info.receiptsSinceLastZ, equals(10));
      expect(info.salesTotalSinceLastZ, equals(250.50));
      expect(info.lastReceiptNumber, equals(1234));
    });

    test('toString returns readable format', () {
      const info = LastFiscalEntryInfo(
        lastZReportNumber: 50,
        receiptsSinceLastZ: 10,
      );

      final str = info.toString();
      expect(str, contains('50'));
      expect(str, contains('10'));
    });
  });

  group('RemainingZReportsInfo', () {
    test('creates with default values', () {
      const info = RemainingZReportsInfo();

      expect(info.remainingZReports, equals(0));
      expect(info.totalCapacity, equals(2500));
      expect(info.usedZReports, equals(0));
    });

    test('percentUsed calculates correctly', () {
      const info = RemainingZReportsInfo(
        remainingZReports: 2000,
        totalCapacity: 2500,
        usedZReports: 500,
      );

      expect(info.percentUsed, equals(20.0));
    });

    test('percentUsed returns 0 when totalCapacity is 0', () {
      const info = RemainingZReportsInfo(totalCapacity: 0);
      expect(info.percentUsed, equals(0.0));
    });

    test('fromResponse parses tab-separated values', () {
      final info = RemainingZReportsInfo.fromResponse('2400\t2500');

      expect(info.remainingZReports, equals(2400));
      expect(info.totalCapacity, equals(2500));
      expect(info.usedZReports, equals(100));
    });

    test('toString contains key information', () {
      const info = RemainingZReportsInfo(
        remainingZReports: 2400,
        totalCapacity: 2500,
      );

      final str = info.toString();
      expect(str, contains('2400'));
      expect(str, contains('2500'));
    });
  });

  group('FiscalMemoryTestResult', () {
    test('creates with default values', () {
      const result = FiscalMemoryTestResult();

      expect(result.isOk, isFalse);
      expect(result.errorMessage, isEmpty);
      expect(result.recordsCount, equals(0));
    });

    test('fromResponse parses success response', () {
      final result = FiscalMemoryTestResult.fromResponse('0\t\t100\tABCD1234');

      expect(result.isOk, isTrue);
      expect(result.recordsCount, equals(100));
      expect(result.checksum, equals('ABCD1234'));
    });

    test('fromResponse parses error response', () {
      final result = FiscalMemoryTestResult.fromResponse('1\tMemory error');

      expect(result.isOk, isFalse);
      expect(result.errorMessage, equals('Memory error'));
    });
  });

  group('LastFiscalRecordDate', () {
    test('creates with null values', () {
      const info = LastFiscalRecordDate();

      expect(info.date, isNull);
      expect(info.time, isNull);
    });

    test('fromResponse parses date', () {
      final info = LastFiscalRecordDate.fromResponse('15-01-24\t14:30:00');

      expect(info.date, isNotNull);
      expect(info.date!.day, equals(15));
      expect(info.date!.month, equals(1));
      expect(info.date!.year, equals(2024));
    });

    test('toString contains date info', () {
      final info = LastFiscalRecordDate(date: DateTime(2024, 1, 15));
      final str = info.toString();
      expect(str, contains('2024-01-15'));
    });
  });

  group('FiscalizationInfo', () {
    test('creates with default values', () {
      const info = FiscalizationInfo();

      expect(info.taxNumber, isEmpty);
      expect(info.fiscalSerialNumber, isEmpty);
      expect(info.fiscalizationDate, isNull);
    });

    test('toString contains key information', () {
      const info = FiscalizationInfo(
        taxNumber: 'RO12345678',
        fiscalSerialNumber: 'FM001',
      );

      final str = info.toString();
      expect(str, contains('RO12345678'));
      expect(str, contains('FM001'));
    });
  });
}
