import 'package:datecs_sk1_21/datecs_sk1_21.dart';
import 'package:test/test.dart';

void main() {
  group('Rs232Config', () {
    test('creates with required parameters', () {
      const config = Rs232Config(comPort: 4);

      expect(config.comPort, equals(4));
      expect(config.baudRate, equals(115200)); // Default
    });

    test('creates with custom baud rate', () {
      const config = Rs232Config(comPort: 3, baudRate: 9600);

      expect(config.comPort, equals(3));
      expect(config.baudRate, equals(9600));
    });

    test('toString returns formatted string', () {
      const config = Rs232Config(comPort: 4, baudRate: 115200);

      expect(config.toString(), equals('Rs232Config(COM4, 115200 baud)'));
    });
  });

  group('TcpIpConfig', () {
    test('creates with required parameters', () {
      const config = TcpIpConfig(address: '192.168.1.100');

      expect(config.address, equals('192.168.1.100'));
      expect(config.port, equals(3999)); // Default
    });

    test('creates with custom port', () {
      const config = TcpIpConfig(address: '10.0.0.1', port: 8080);

      expect(config.address, equals('10.0.0.1'));
      expect(config.port, equals(8080));
    });

    test('toString returns formatted string', () {
      const config = TcpIpConfig(address: '192.168.1.100', port: 3999);

      expect(config.toString(), equals('TcpIpConfig(192.168.1.100:3999)'));
    });
  });

  group('DeviceInfo', () {
    test('creates with all parameters', () {
      const info = DeviceInfo(
        model: 'SK1-21',
        serialNumber: 'DB4020000539',
        firmwareVersion: '417320 02Nov20 1000',
        codePage: '1251',
        distributor: 'Datecs',
        isFiscalPrinter: true,
      );

      expect(info.model, equals('SK1-21'));
      expect(info.serialNumber, equals('DB4020000539'));
      expect(info.firmwareVersion, equals('417320 02Nov20 1000'));
      expect(info.codePage, equals('1251'));
      expect(info.distributor, equals('Datecs'));
      expect(info.isFiscalPrinter, isTrue);
    });

    test('toString contains all fields', () {
      const info = DeviceInfo(
        model: 'SK1-21',
        serialNumber: 'SN123',
        firmwareVersion: '1.0',
        codePage: '1251',
        distributor: 'Datecs',
        isFiscalPrinter: true,
      );

      final str = info.toString();
      expect(str, contains('SK1-21'));
      expect(str, contains('SN123'));
      expect(str, contains('1.0'));
    });
  });

  group('TransportProtocol', () {
    test('has rs232 value', () {
      expect(TransportProtocol.rs232, isNotNull);
    });

    test('has tcpip value', () {
      expect(TransportProtocol.tcpip, isNotNull);
    });
  });
}
