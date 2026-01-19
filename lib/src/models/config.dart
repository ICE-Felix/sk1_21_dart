/// Configuration for Datecs SK1-21 printer communication.

/// Transport type for printer connection.
enum TransportProtocol {
  /// RS232 serial connection (COM port).
  rs232,

  /// TCP/IP network connection.
  tcpip,
}

/// Configuration for RS232 connection.
class Rs232Config {
  /// COM port number (e.g.: 4 for COM4).
  final int comPort;

  /// Baud rate.
  /// Default: 115200 for SK1-21.
  final int baudRate;

  const Rs232Config({
    required this.comPort,
    this.baudRate = 115200,
  });

  @override
  String toString() => 'Rs232Config(COM$comPort, $baudRate baud)';
}

/// Configuration for TCP/IP connection.
class TcpIpConfig {
  /// IP address of printer or LDREST server.
  final String address;

  /// TCP port.
  /// Default: 3999 for DUDE server.
  final int port;

  const TcpIpConfig({
    required this.address,
    this.port = 3999,
  });

  @override
  String toString() => 'TcpIpConfig($address:$port)';
}

/// Information about connected Datecs device.
class DeviceInfo {
  /// Device model (e.g.: SK1-21).
  final String model;

  /// Serial number.
  final String serialNumber;

  /// Firmware version.
  final String firmwareVersion;

  /// Code page used (e.g.: 1251).
  final String codePage;

  /// Distributor.
  final String distributor;

  /// True if it's a fiscal printer.
  final bool isFiscalPrinter;

  const DeviceInfo({
    required this.model,
    required this.serialNumber,
    required this.firmwareVersion,
    required this.codePage,
    required this.distributor,
    required this.isFiscalPrinter,
  });

  @override
  String toString() => '''DeviceInfo(
  model: $model,
  serialNumber: $serialNumber,
  firmwareVersion: $firmwareVersion,
  codePage: $codePage,
  distributor: $distributor,
  isFiscalPrinter: $isFiscalPrinter
)''';
}
