import 'package:datecs_sk1_21/datecs_sk1_21.dart';
import 'package:test/test.dart';

void main() {
  group('PrinterStatus', () {
    test('creates with all defaults as false', () {
      const status = PrinterStatus();

      expect(status.syntaxError, isFalse);
      expect(status.invalidCommand, isFalse);
      expect(status.paperOut, isFalse);
      expect(status.fiscalReceiptOpen, isFalse);
      expect(status.fiscalized, isFalse);
    });

    test('hasError returns true when any error flag is set', () {
      const status = PrinterStatus(syntaxError: true);
      expect(status.hasError, isTrue);

      const status2 = PrinterStatus(generalError: true);
      expect(status2.hasError, isTrue);

      const status3 = PrinterStatus(printHeadOverheat: true);
      expect(status3.hasError, isTrue);
    });

    test('hasError returns false when no error flags', () {
      const status = PrinterStatus(paperNearEnd: true);
      expect(status.hasError, isFalse);
    });

    test('isReady returns true when no blocking conditions', () {
      const status = PrinterStatus();
      expect(status.isReady, isTrue);
    });

    test('isReady returns false when paper is out', () {
      const status = PrinterStatus(paperOut: true);
      expect(status.isReady, isFalse);
    });

    test('isReady returns false when cover is open', () {
      const status = PrinterStatus(coverOpen: true);
      expect(status.isReady, isFalse);
    });

    test('receiptOpen returns true when fiscal receipt open', () {
      const status = PrinterStatus(fiscalReceiptOpen: true);
      expect(status.receiptOpen, isTrue);
    });

    test('receiptOpen returns true when non-fiscal receipt open', () {
      const status = PrinterStatus(nonFiscalReceiptOpen: true);
      expect(status.receiptOpen, isTrue);
    });

    test('fromBytes parses status bytes correctly', () {
      // Create test bytes with specific flags set
      final bytes = [
        0x01, // S0: syntaxError
        0x00, // S1: no flags
        0x02, // S2: paperNearEnd
        0x02, // S3: fiscalReceiptOpen
        0x01, // S4: fiscalized
        0x01, // S5: displayConnected
      ];

      final status = PrinterStatus.fromBytes(bytes);

      expect(status.syntaxError, isTrue);
      expect(status.paperNearEnd, isTrue);
      expect(status.fiscalReceiptOpen, isTrue);
      expect(status.fiscalized, isTrue);
      expect(status.displayConnected, isTrue);
    });

    test('fromBytes returns defaults for insufficient bytes', () {
      final status = PrinterStatus.fromBytes([0x01, 0x02]);
      expect(status.syntaxError, isFalse); // Returns default
    });

    test('toString contains key information', () {
      const status = PrinterStatus(
        fiscalReceiptOpen: true,
        paperNearEnd: true,
      );

      final str = status.toString();
      expect(str, contains('fiscalReceiptOpen: true'));
      expect(str, contains('paperNearEnd: true'));
    });
  });

  group('ReceiptStatus', () {
    test('creates with default values', () {
      const status = ReceiptStatus();

      expect(status.isOpen, isFalse);
      expect(status.salesCount, equals(0));
      expect(status.subtotal, equals(0.0));
      expect(status.isFiscal, isFalse);
      expect(status.receiptNumber, equals(0));
    });

    test('fromResponse parses tab-separated values', () {
      final status = ReceiptStatus.fromResponse('1\t5\t125.50\t1\t1234');

      expect(status.isOpen, isTrue);
      expect(status.salesCount, equals(5));
      expect(status.subtotal, equals(125.50));
      expect(status.isFiscal, isTrue);
      expect(status.receiptNumber, equals(1234));
    });

    test('fromResponse handles empty response', () {
      final status = ReceiptStatus.fromResponse('');
      expect(status.isOpen, isFalse);
    });

    test('toString returns readable format', () {
      const status = ReceiptStatus(isOpen: true, salesCount: 3, subtotal: 50.0);
      expect(status.toString(), contains('open: true'));
      expect(status.toString(), contains('sales: 3'));
    });
  });

  group('ReceiptInfo', () {
    test('creates with default values', () {
      const info = ReceiptInfo();

      expect(info.isOpen, isFalse);
      expect(info.salesCount, equals(0));
      expect(info.subtotalNet, equals(0.0));
      expect(info.totalVat, equals(0.0));
      expect(info.totalGross, equals(0.0));
    });

    test('fromResponse parses tab-separated values', () {
      final info =
          ReceiptInfo.fromResponse('1\t3\t100.00\t19.00\t119.00\t5678\tUSN123');

      expect(info.isOpen, isTrue);
      expect(info.salesCount, equals(3));
      expect(info.subtotalNet, equals(100.0));
      expect(info.totalVat, equals(19.0));
      expect(info.totalGross, equals(119.0));
      expect(info.receiptNumber, equals(5678));
      expect(info.uniqueSaleNumber, equals('USN123'));
    });
  });

  group('DiagnosticInfo', () {
    test('creates with default values', () {
      const info = DiagnosticInfo();

      expect(info.firmwareVersion, isEmpty);
      expect(info.serialNumber, isEmpty);
      expect(info.totalRam, equals(0));
      expect(info.freeRam, equals(0));
    });

    test('fromResponse parses tab-separated values', () {
      final info = DiagnosticInfo.fromResponse(
        '1.0\t01Jan24\tSN123\tFM456\t65536\t32768\tSK1-21\tABCD\t1251\tRO',
      );

      expect(info.firmwareVersion, equals('1.0'));
      expect(info.firmwareDate, equals('01Jan24'));
      expect(info.serialNumber, equals('SN123'));
      expect(info.fiscalMemorySerial, equals('FM456'));
      expect(info.totalRam, equals(65536));
      expect(info.freeRam, equals(32768));
      expect(info.model, equals('SK1-21'));
    });

    test('ramUsagePercent calculates correctly', () {
      const info = DiagnosticInfo(totalRam: 100, freeRam: 25);
      expect(info.ramUsagePercent, equals(75.0));
    });

    test('ramUsagePercent returns 0 when totalRam is 0', () {
      const info = DiagnosticInfo(totalRam: 0, freeRam: 0);
      expect(info.ramUsagePercent, equals(0.0));
    });
  });

  group('PrinterMode', () {
    test('has correct codes', () {
      expect(PrinterMode.normal.code, equals(0));
      expect(PrinterMode.programming.code, equals(1));
      expect(PrinterMode.service.code, equals(2));
      expect(PrinterMode.fiscalization.code, equals(3));
    });
  });
}
