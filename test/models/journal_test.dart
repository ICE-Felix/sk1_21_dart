import 'package:datecs_sk1_21/datecs_sk1_21.dart';
import 'package:test/test.dart';

void main() {
  group('JournalInfo', () {
    test('creates with default values', () {
      const info = JournalInfo();

      expect(info.totalRecords, equals(0));
      expect(info.firstRecordNumber, equals(0));
      expect(info.lastRecordNumber, equals(0));
      expect(info.usedSpaceKb, equals(0));
      expect(info.totalSpaceKb, equals(0));
    });

    test('percentUsed calculates correctly', () {
      const info = JournalInfo(usedSpaceKb: 500, totalSpaceKb: 1000);
      expect(info.percentUsed, equals(50.0));
    });

    test('percentUsed returns 0 when totalSpaceKb is 0', () {
      const info = JournalInfo(totalSpaceKb: 0);
      expect(info.percentUsed, equals(0.0));
    });

    test('fromResponse parses tab-separated values', () {
      final info = JournalInfo.fromResponse(
        '1000\t1\t1000\t01-01-24\t15-01-24\t500\t2048',
      );

      expect(info.totalRecords, equals(1000));
      expect(info.firstRecordNumber, equals(1));
      expect(info.lastRecordNumber, equals(1000));
      expect(info.usedSpaceKb, equals(500));
      expect(info.totalSpaceKb, equals(2048));
    });

    test('toString contains key information', () {
      const info = JournalInfo(totalRecords: 500, usedSpaceKb: 250);
      final str = info.toString();
      expect(str, contains('500'));
    });
  });

  group('JournalSearchResult', () {
    test('creates with default values', () {
      const result = JournalSearchResult();

      expect(result.recordNumber, equals(0));
      expect(result.date, isNull);
      expect(result.type, equals(JournalRecordType.unknown));
    });

    test('fromResponse parses tab-separated values', () {
      final result = JournalSearchResult.fromResponse(
        '100\t15-01-24 14:30:00\tF\t1234\t50',
      );

      expect(result.recordNumber, equals(100));
      expect(result.type, equals(JournalRecordType.fiscalReceipt));
      expect(result.receiptNumber, equals(1234));
      expect(result.zReportNumber, equals(50));
    });

    test('toString contains key information', () {
      const result = JournalSearchResult(
        recordNumber: 100,
        type: JournalRecordType.fiscalReceipt,
      );
      final str = result.toString();
      expect(str, contains('100'));
      expect(str, contains('fiscalReceipt'));
    });
  });

  group('JournalRecordType', () {
    test('has correct codes', () {
      expect(JournalRecordType.unknown.code, equals('U'));
      expect(JournalRecordType.fiscalReceipt.code, equals('F'));
      expect(JournalRecordType.nonFiscalReceipt.code, equals('N'));
      expect(JournalRecordType.zReport.code, equals('Z'));
      expect(JournalRecordType.xReport.code, equals('X'));
      expect(JournalRecordType.cashIn.code, equals('I'));
      expect(JournalRecordType.cashOut.code, equals('O'));
      expect(JournalRecordType.cancelled.code, equals('C'));
      expect(JournalRecordType.service.code, equals('S'));
    });

    test('fromCode returns correct type', () {
      expect(JournalRecordType.fromCode('F'),
          equals(JournalRecordType.fiscalReceipt));
      expect(
          JournalRecordType.fromCode('Z'), equals(JournalRecordType.zReport));
      expect(
          JournalRecordType.fromCode('?'), equals(JournalRecordType.unknown));
    });

    test('has descriptions', () {
      expect(JournalRecordType.fiscalReceipt.description, isNotEmpty);
      expect(JournalRecordType.zReport.description, isNotEmpty);
    });
  });

  group('XmlExportConfig', () {
    test('creates with required path', () {
      const config = XmlExportConfig(path: 'C:\\export');

      expect(config.path, equals('C:\\export'));
      expect(config.includeDetails, isTrue);
    });

    test('toCommandData generates correct format with dates', () {
      final config = XmlExportConfig(
        path: 'C:\\export',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      final data = config.toCommandData();
      expect(data, contains('C:\\export'));
      expect(data, contains('01-01-24'));
      expect(data, contains('31-01-24'));
    });

    test('toCommandData generates correct format with Z numbers', () {
      const config = XmlExportConfig(
        path: 'C:\\export',
        startZNumber: 1,
        endZNumber: 100,
      );

      final data = config.toCommandData();
      expect(data, contains('Z1'));
      expect(data, contains('Z100'));
    });
  });

  group('XmlExportResult', () {
    test('creates with default values', () {
      const result = XmlExportResult();

      expect(result.success, isFalse);
      expect(result.filePath, isEmpty);
      expect(result.recordsExported, equals(0));
      expect(result.errorMessage, isEmpty);
    });

    test('toString contains key information', () {
      const result = XmlExportResult(
        success: true,
        filePath: 'C:\\export\\data.xml',
        recordsExported: 100,
      );

      final str = result.toString();
      expect(str, contains('true'));
      expect(str, contains('100'));
    });
  });
}
