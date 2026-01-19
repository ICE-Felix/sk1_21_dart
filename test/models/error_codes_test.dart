import 'package:datecs_sk1_21/datecs_sk1_21.dart';
import 'package:test/test.dart';

void main() {
  group('DatecsErrorCode', () {
    test('success has code 0', () {
      expect(DatecsErrorCode.success.code, equals(0));
      expect(DatecsErrorCode.success.description, equals('No error'));
    });

    test('fromCode returns correct error for known code', () {
      expect(DatecsErrorCode.fromCode(0), equals(DatecsErrorCode.success));
      expect(DatecsErrorCode.fromCode(1), equals(DatecsErrorCode.syntaxError));
      expect(DatecsErrorCode.fromCode(18), equals(DatecsErrorCode.paperOut));
    });

    test('fromCode returns unknown for unrecognized code', () {
      expect(DatecsErrorCode.fromCode(999), equals(DatecsErrorCode.unknown));
    });

    test('isCritical returns true for critical errors', () {
      expect(DatecsErrorCode.fiscalMemoryError.isCritical, isTrue);
      expect(DatecsErrorCode.fiscalMemoryFull.isCritical, isTrue);
      expect(DatecsErrorCode.ramError.isCritical, isTrue);
      expect(DatecsErrorCode.journalFull.isCritical, isTrue);
    });

    test('isCritical returns false for non-critical errors', () {
      expect(DatecsErrorCode.paperOut.isCritical, isFalse);
      expect(DatecsErrorCode.syntaxError.isCritical, isFalse);
    });

    test('isPaperError returns true only for paper errors', () {
      expect(DatecsErrorCode.paperOut.isPaperError, isTrue);
      expect(DatecsErrorCode.coverOpen.isPaperError, isFalse);
    });

    test('isHardwareError returns true for hardware errors', () {
      expect(DatecsErrorCode.paperOut.isHardwareError, isTrue);
      expect(DatecsErrorCode.printHeadOverheat.isHardwareError, isTrue);
      expect(DatecsErrorCode.cutterError.isHardwareError, isTrue);
      expect(DatecsErrorCode.coverOpen.isHardwareError, isTrue);
      expect(DatecsErrorCode.printerError.isHardwareError, isTrue);
    });

    test('isHardwareError returns false for non-hardware errors', () {
      expect(DatecsErrorCode.syntaxError.isHardwareError, isFalse);
      expect(DatecsErrorCode.wrongPassword.isHardwareError, isFalse);
    });

    test('isCommunicationError returns true for communication errors', () {
      expect(DatecsErrorCode.communicationError.isCommunicationError, isTrue);
      expect(DatecsErrorCode.timeout.isCommunicationError, isTrue);
      expect(DatecsErrorCode.connectionLost.isCommunicationError, isTrue);
    });

    test('isCommunicationError returns false for non-communication errors', () {
      expect(DatecsErrorCode.paperOut.isCommunicationError, isFalse);
    });

    test('toString returns formatted string', () {
      final str = DatecsErrorCode.paperOut.toString();
      expect(str, contains('paperOut'));
      expect(str, contains('18'));
      expect(str, contains('Paper out'));
    });

    test('DUDE driver errors have negative codes', () {
      expect(DatecsErrorCode.dudePortError.code, isNegative);
      expect(DatecsErrorCode.dudeTimeout.code, isNegative);
      expect(DatecsErrorCode.dudeConnectionError.code, isNegative);
    });
  });

  group('DatecsErrorCodeParsing extension', () {
    test('toDatecsError converts int to error code', () {
      expect(0.toDatecsError(), equals(DatecsErrorCode.success));
      expect(18.toDatecsError(), equals(DatecsErrorCode.paperOut));
      expect(999.toDatecsError(), equals(DatecsErrorCode.unknown));
    });
  });
}
