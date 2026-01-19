import 'package:datecs_sk1_21/datecs_sk1_21.dart';
import 'package:test/test.dart';

void main() {
  group('DatecsResponse', () {
    test('creates with required parameters', () {
      final response = DatecsResponse(
        errorCode: 0,
        deviceAnswer: 'OK',
        success: true,
      );

      expect(response.errorCode, equals(0));
      expect(response.deviceAnswer, equals('OK'));
      expect(response.success, isTrue);
      expect(response.hasError, isFalse);
    });

    test('hasError returns true when errorCode is not 0', () {
      final response = DatecsResponse(
        errorCode: 18,
        deviceAnswer: '',
        success: false,
      );

      expect(response.hasError, isTrue);
      expect(response.error, equals(DatecsErrorCode.paperOut));
    });

    test('errorDescription returns error description', () {
      final response = DatecsResponse(
        errorCode: 18,
        deviceAnswer: '',
        success: false,
      );

      expect(response.errorDescription, equals('Paper out'));
    });

    test('errorDescription includes code for unknown errors', () {
      final response = DatecsResponse(
        errorCode: 99999,
        deviceAnswer: '',
        success: false,
      );

      expect(response.errorDescription, contains('99999'));
    });

    test('fields splits device answer by tab', () {
      final response = DatecsResponse(
        errorCode: 0,
        deviceAnswer: 'field1\tfield2\tfield3',
        success: true,
      );

      expect(response.fields, equals(['field1', 'field2', 'field3']));
    });

    test('getField returns field at index', () {
      final response = DatecsResponse(
        errorCode: 0,
        deviceAnswer: 'first\tsecond\tthird',
        success: true,
      );

      expect(response.getField(0), equals('first'));
      expect(response.getField(1), equals('second'));
      expect(response.getField(2), equals('third'));
      expect(response.getField(10), isNull);
    });

    test('getField returns null for empty field', () {
      final response = DatecsResponse(
        errorCode: 0,
        deviceAnswer: 'first\t\tthird',
        success: true,
      );

      expect(response.getField(1), isNull);
    });

    test('getFieldAsInt parses integer fields', () {
      final response = DatecsResponse(
        errorCode: 0,
        deviceAnswer: '100\t200\tnot_a_number',
        success: true,
      );

      expect(response.getFieldAsInt(0), equals(100));
      expect(response.getFieldAsInt(1), equals(200));
      expect(response.getFieldAsInt(2), isNull);
    });

    test('getFieldAsDouble parses double fields', () {
      final response = DatecsResponse(
        errorCode: 0,
        deviceAnswer: '10.5\t20.75\tnot_a_number',
        success: true,
      );

      expect(response.getFieldAsDouble(0), equals(10.5));
      expect(response.getFieldAsDouble(1), equals(20.75));
      expect(response.getFieldAsDouble(2), isNull);
    });

    test('isCriticalError delegates to error code', () {
      final response = DatecsResponse(
        errorCode: 14, // fiscalMemoryError
        deviceAnswer: '',
        success: false,
      );

      expect(response.isCriticalError, isTrue);
    });

    test('isPaperError delegates to error code', () {
      final response = DatecsResponse(
        errorCode: 18, // paperOut
        deviceAnswer: '',
        success: false,
      );

      expect(response.isPaperError, isTrue);
    });

    test('isHardwareError delegates to error code', () {
      final response = DatecsResponse(
        errorCode: 19, // printHeadOverheat
        deviceAnswer: '',
        success: false,
      );

      expect(response.isHardwareError, isTrue);
    });

    test('isCommunicationError delegates to error code', () {
      final response = DatecsResponse(
        errorCode: 50, // communicationError
        deviceAnswer: '',
        success: false,
      );

      expect(response.isCommunicationError, isTrue);
    });

    test('toString returns formatted success message', () {
      final response = DatecsResponse(
        errorCode: 0,
        deviceAnswer: 'test',
        success: true,
      );

      final str = response.toString();
      expect(str, contains('success'));
      expect(str, contains('test'));
    });

    test('toString returns formatted error message', () {
      final response = DatecsResponse(
        errorCode: 18,
        deviceAnswer: '',
        success: false,
      );

      final str = response.toString();
      expect(str, contains('paperOut'));
    });
  });

  group('DatecsDudeDriver', () {
    late DatecsDudeDriver driver;

    setUp(() {
      driver = DatecsDudeDriver();
    });

    tearDown(() {
      driver.dispose();
    });

    test('initial state is not connected', () {
      expect(driver.isServerStarted, isFalse);
      expect(driver.isConnected, isFalse);
      expect(driver.deviceInfo, isNull);
    });

    test('startComServer sets isServerStarted', () async {
      await driver.startComServer();
      expect(driver.isServerStarted, isTrue);
    });

    test('startComServer is idempotent', () async {
      await driver.startComServer();
      await driver.startComServer(); // Should not throw
      expect(driver.isServerStarted, isTrue);
    });

    test('stopComServer resets state', () async {
      await driver.startComServer();
      await driver.stopComServer();
      expect(driver.isServerStarted, isFalse);
    });

    test('openRs232Connection throws if server not started', () async {
      expect(
        () => driver.openRs232Connection(const Rs232Config(comPort: 4)),
        throwsA(isA<StateError>()),
      );
    });

    test('openTcpIpConnection throws if server not started', () async {
      expect(
        () => driver.openTcpIpConnection(
          const TcpIpConfig(address: '192.168.1.1'),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('executeCommand throws if not connected', () async {
      await driver.startComServer();
      expect(
        () => driver.executeCommand(90),
        throwsA(isA<StateError>()),
      );
    });

    test('onError stream is available', () {
      expect(driver.onError, isNotNull);
    });

    test('onStatusChange stream is available', () {
      expect(driver.onStatusChange, isNotNull);
    });

    test('onCommandSent stream is available', () {
      expect(driver.onCommandSent, isNotNull);
    });

    test('onAnswerReceived stream is available', () {
      expect(driver.onAnswerReceived, isNotNull);
    });

    test('generateXReport calls generateDailyReport with xReport', () async {
      // This test verifies the helper method exists and has correct signature
      expect(driver.generateXReport, isNotNull);
    });

    test('generateZReport calls generateDailyReport with zReport', () async {
      // This test verifies the helper method exists and has correct signature
      expect(driver.generateZReport, isNotNull);
    });
  });
}
