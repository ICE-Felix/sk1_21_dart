import 'package:datecs_sk1_21/datecs_sk1_21.dart';
import 'package:test/test.dart';

void main() {
  group('DailyReportType', () {
    test('has correct codes', () {
      expect(DailyReportType.xReport.code, equals('X'));
      expect(DailyReportType.zReport.code, equals('Z'));
      expect(DailyReportType.ecrReport.code, equals('E'));
      expect(DailyReportType.departmentsReport.code, equals('D'));
      expect(DailyReportType.itemGroupsReport.code, equals('G'));
    });
  });

  group('DailyReportResult', () {
    test('creates with required reportNumber', () {
      const result = DailyReportResult(reportNumber: 100);

      expect(result.reportNumber, equals(100));
      expect(result.totalA, equals(0.0));
      expect(result.totalB, equals(0.0));
    });

    test('grandTotal sums all tax group totals', () {
      const result = DailyReportResult(
        reportNumber: 1,
        totalA: 100.0,
        totalB: 200.0,
        totalC: 50.0,
        totalD: 25.0,
        totalE: 10.0,
        totalF: 5.0,
        totalExempt: 10.0,
      );

      expect(result.grandTotal, equals(400.0));
    });

    test('toString contains report number and total', () {
      const result = DailyReportResult(
        reportNumber: 50,
        totalA: 100.0,
        totalB: 200.0,
      );

      final str = result.toString();
      expect(str, contains('50'));
      expect(str, contains('300.0')); // grandTotal
    });
  });
}
