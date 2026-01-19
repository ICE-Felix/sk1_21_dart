# Ghid de Implementare Dart - Datecs Fiscal Printer

Acest document descrie fluxul de inițializare și conexiune pentru imprimanta fiscală Datecs, bazat pe analiza aplicației demo C#.

## Cuprins

1. [Arhitectura Generală](#arhitectura-generală)
2. [Start COM Server](#start-com-server)
3. [Configurare Conexiune RS232](#configurare-conexiune-rs232)
4. [Open Connection](#open-connection)
5. [Implementare Dart](#implementare-dart)

---

## Arhitectura Generală

Comunicarea cu imprimanta Datecs se face printr-un server COM intermediar numit **CFD_DUDE** (Datecs Universal Driver Engine). Acest driver abstractizează complexitatea protocolului și oferă o interfață unificată pentru:

- **RS232** - Comunicare serială directă
- **TCPIP** - Comunicare prin rețea

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Aplicație Dart │────▶│  CFD_DUDE COM    │────▶│  Imprimantă     │
│                 │     │  Server          │     │  Datecs SK1-21  │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                              │
                              ├── RS232 (COM4, 115200)
                              └── TCPIP (IP:Port)
```

---

## Start COM Server

### Ce face butonul "Start - COM Server"

**Locație în cod**: `MainForm.cs:945-1017`

### Fluxul de execuție:

#### 1. Inițializare obiect COM

```csharp
// Încearcă să obțină o instanță existentă
serv = (CFD_DUDE)Marshal.GetActiveObject("dude.CFD_DUDE");

// Dacă nu există, creează una nouă
serv = new CFD_DUDE();
```

**Ce înseamnă**: Pornește driver-ul DUDE în memorie. La acest pas NU se deschide nicio conexiune fizică.

#### 2. Înregistrare Event Handlers

Serverul COM emite evenimente pentru monitorizare:

| Eveniment | Descriere |
|-----------|-----------|
| `OnError` | Erori de comunicare |
| `OnBeforeScriptExecute` | Înainte de execuție comandă |
| `OnScriptRowExecute` | Execuție linie script |
| `OnReceiveAnswer` | Răspuns primit de la imprimantă |
| `OnSendCommand` | Comandă trimisă către imprimantă |
| `OnStatusChange` | Schimbare status imprimantă |
| `OnAfterOpenConnection` | După deschidere conexiune |
| `OnAfterCloseConnection` | După închidere conexiune |

#### 3. Citire setări existente

După pornire, serverul expune setările curente:

```csharp
tbx_ComPort.Text = serv.rs232_ComPort.ToString();    // Port COM (ex: 4)
tbx_BaudRate.Text = serv.rs232_BaudRate.ToString();  // Baud rate (ex: 115200)
tbx_IPAddress.Text = serv.tcpip_Address;             // Adresă IP
tbx_LANPort.Text = serv.tcpip_Port.ToString();       // Port TCP (ex: 3999)
```

### Stare după "Start COM Server":

- ✅ Obiect COM inițializat în memorie
- ✅ Event handlers înregistrate
- ✅ Setări încărcate și afișate în UI
- ❌ **NU** s-a deschis portul serial
- ❌ **NU** s-a conectat la imprimantă

---

## Configurare Conexiune RS232

### Parametri de configurare

| Parametru | Valoare | Descriere |
|-----------|---------|-----------|
| **Tip Transport** | RS232 | Comunicare serială |
| **COM Port** | COM4 | Port serial fizic |
| **Baud Rate** | 115200 | Viteză comunicare |
| **Data Bits** | 8 | Fix (implicit în driver) |
| **Parity** | None | Fix (implicit în driver) |
| **Stop Bits** | 1 | Fix (implicit în driver) |

### Configurare TCPIP (alternativă)

| Parametru | Valoare | Descriere |
|-----------|---------|-----------|
| **Tip Transport** | TCPIP | Comunicare rețea |
| **IP Address** | 127.0.0.1 | Adresa serverului/imprimantei |
| **Port** | 3999 | Port TCP |

### Selectare tip transport

```csharp
// Index 0 = RS232
// Index 1 = TCPIP
cbx_ToggleSwitch.SelectedIndex = 0; // Pentru RS232
```

---

## Open Connection

### Ce face butonul "Open Connection"

**Locație în cod**: `MainForm.cs:1514-1581`

### Fluxul de execuție:

#### 1. Verificare pre-condiții

```csharp
if (!fCOMServer_Started) return; // COM server trebuie pornit
```

#### 2. Setare tip transport

```csharp
// Pentru RS232
error_Code = serv.set_TransportType(TTransportProtocol.ctc_RS232);

// Pentru TCPIP
error_Code = serv.set_TransportType(TTransportProtocol.ctc_TCPIP);
```

#### 3. Configurare parametri conexiune

**RS232:**
```csharp
error_Code = serv.set_RS232(
    Int32.Parse(tbx_ComPort.Text),    // 4
    Int32.Parse(tbx_BaudRate.Text)    // 115200
);
```

**TCPIP:**
```csharp
error_Code = serv.set_TCPIP(
    tbx_IPAddress.Text,               // "127.0.0.1"
    (ushort)Int32.Parse(tbx_LANPort.Text)  // 3999
);
```

#### 4. Deschidere conexiune fizică

```csharp
error_Code = serv.open_Connection();
```

**⚠️ AICI se deschide efectiv portul serial/socket-ul TCP!**

#### 5. Configurări post-conexiune

```csharp
set_ANAF_Ranges();           // Configurare domenii fiscale ANAF
fDevice_Connected = true;     // Flag conexiune activă
SetDevice_Connected();        // Update UI
```

#### 6. Interogare proprietăți dispozitiv

După conectare, se citesc informații despre imprimantă:

```csharp
serv.device_Type          // Tip: Fiscal Printer / Cash Register
serv.device_Model         // Model: SK1-21
serv.device_SerialNumber  // Număr serie
serv.device_FirmwareVer   // Versiune firmware
serv.device_CodePage      // Code page (ex: 1251)
serv.device_Distributor   // Distribuitor
```

### Stare după "Open Connection":

- ✅ Port serial/socket deschis
- ✅ Comunicare activă cu imprimanta
- ✅ Informații dispozitiv citite
- ✅ Pregătit pentru comenzi (print, rapoarte, etc.)

---

## Implementare Dart

### Structura claselor propuse

```dart
/// Enum pentru tipul de transport
enum TransportProtocol {
  rs232,
  tcpip,
}

/// Configurare RS232
class Rs232Config {
  final int comPort;
  final int baudRate;

  const Rs232Config({
    required this.comPort,
    this.baudRate = 115200,
  });
}

/// Configurare TCPIP
class TcpIpConfig {
  final String address;
  final int port;

  const TcpIpConfig({
    required this.address,
    required this.port,
  });
}

/// Informații dispozitiv
class DeviceInfo {
  final String model;
  final String serialNumber;
  final String firmwareVersion;
  final String codePage;
  final String distributor;
  final bool isFiscalPrinter;

  const DeviceInfo({
    required this.model,
    required this.serialNumber,
    required this.firmwareVersion,
    required this.codePage,
    required this.distributor,
    required this.isFiscalPrinter,
  });
}
```

### Clasa principală DatecsDriver

```dart
import 'dart:async';

/// Driver pentru imprimanta fiscală Datecs
///
/// Abstractizează comunicarea cu serverul DUDE COM
class DatecsDriver {
  bool _isServerStarted = false;
  bool _isConnected = false;
  TransportProtocol? _transportType;
  DeviceInfo? _deviceInfo;

  // Event streams
  final _onError = StreamController<String>.broadcast();
  final _onStatusChange = StreamController<int>.broadcast();
  final _onCommandSent = StreamController<String>.broadcast();
  final _onAnswerReceived = StreamController<String>.broadcast();

  Stream<String> get onError => _onError.stream;
  Stream<int> get onStatusChange => _onStatusChange.stream;
  Stream<String> get onCommandSent => _onCommandSent.stream;
  Stream<String> get onAnswerReceived => _onAnswerReceived.stream;

  bool get isServerStarted => _isServerStarted;
  bool get isConnected => _isConnected;
  DeviceInfo? get deviceInfo => _deviceInfo;

  /// Pasul 1: Pornește COM Server
  ///
  /// Echivalent cu butonul "Start - COM Server"
  /// Inițializează driver-ul DUDE în memorie
  Future<void> startComServer() async {
    if (_isServerStarted) {
      throw StateError('COM Server already started');
    }

    // TODO: Implementare FFI/HTTP pentru inițializare DUDE
    // În practică, aceasta poate fi:
    // 1. Apel FFI către DLL-ul DUDE
    // 2. Verificare că serviciul LDREST rulează
    // 3. Inițializare socket pentru comunicare cu DUDE

    _isServerStarted = true;
  }

  /// Pasul 2: Configurează și deschide conexiunea RS232
  ///
  /// Echivalent cu configurare + "Open Connection"
  Future<void> openRs232Connection(Rs232Config config) async {
    _validateServerStarted();

    // Setare tip transport
    _transportType = TransportProtocol.rs232;

    // Configurare parametri RS232
    // set_TransportType(ctc_RS232)
    // set_RS232(comPort, baudRate)

    // Deschidere conexiune
    // open_Connection()

    await _openConnection();

    // Citire informații dispozitiv
    await _readDeviceInfo();

    _isConnected = true;
  }

  /// Pasul 2 alternativ: Configurează și deschide conexiunea TCPIP
  Future<void> openTcpIpConnection(TcpIpConfig config) async {
    _validateServerStarted();

    _transportType = TransportProtocol.tcpip;

    // set_TransportType(ctc_TCPIP)
    // set_TCPIP(address, port)

    await _openConnection();
    await _readDeviceInfo();

    _isConnected = true;
  }

  /// Închide conexiunea
  Future<void> closeConnection() async {
    if (!_isConnected) return;

    // close_Connection()

    _isConnected = false;
    _deviceInfo = null;
  }

  /// Oprește COM Server
  Future<void> stopComServer() async {
    if (_isConnected) {
      await closeConnection();
    }

    _isServerStarted = false;
  }

  void _validateServerStarted() {
    if (!_isServerStarted) {
      throw StateError('COM Server not started. Call startComServer() first.');
    }
  }

  void _validateConnected() {
    if (!_isConnected) {
      throw StateError('Not connected. Call openRs232Connection() or openTcpIpConnection() first.');
    }
  }

  Future<void> _openConnection() async {
    // Implementare specifică platformei
    // Apel către DUDE: open_Connection()
  }

  Future<void> _readDeviceInfo() async {
    // Citire proprietăți dispozitiv de la DUDE
    // device_Type, device_Model, device_SerialNumber, etc.

    _deviceInfo = DeviceInfo(
      model: 'SK1-21',
      serialNumber: '00000000',
      firmwareVersion: '1.0.0',
      codePage: '1251',
      distributor: 'Datecs',
      isFiscalPrinter: true,
    );
  }

  void dispose() {
    _onError.close();
    _onStatusChange.close();
    _onCommandSent.close();
    _onAnswerReceived.close();
  }
}
```

### Exemplu de utilizare

```dart
void main() async {
  final driver = DatecsDriver();

  try {
    // Pasul 1: Pornire COM Server (echivalent "Start - COM Server")
    print('Pornire COM Server...');
    await driver.startComServer();
    print('COM Server pornit ✓');

    // Pasul 2: Deschidere conexiune RS232 (echivalent configurare + "Open Connection")
    print('Deschidere conexiune COM4 @ 115200...');
    await driver.openRs232Connection(
      Rs232Config(comPort: 4, baudRate: 115200),
    );
    print('Conectat ✓');

    // Afișare informații dispozitiv
    final info = driver.deviceInfo;
    if (info != null) {
      print('Model: ${info.model}');
      print('Serie: ${info.serialNumber}');
      print('Firmware: ${info.firmwareVersion}');
    }

    // ... utilizare driver pentru comenzi ...

    // Închidere
    await driver.closeConnection();
    await driver.stopComServer();

  } catch (e) {
    print('Eroare: $e');
  } finally {
    driver.dispose();
  }
}
```

---

## Diagrama secvențială completă

```
┌────────┐          ┌─────────────┐          ┌──────────┐
│  App   │          │  CFD_DUDE   │          │ Printer  │
└───┬────┘          └──────┬──────┘          └────┬─────┘
    │                      │                      │
    │  startComServer()    │                      │
    │─────────────────────▶│                      │
    │                      │                      │
    │  [Server Started]    │                      │
    │◀─────────────────────│                      │
    │                      │                      │
    │  set_TransportType() │                      │
    │─────────────────────▶│                      │
    │                      │                      │
    │  set_RS232(4, 115200)│                      │
    │─────────────────────▶│                      │
    │                      │                      │
    │  open_Connection()   │                      │
    │─────────────────────▶│  [Open COM4]         │
    │                      │─────────────────────▶│
    │                      │                      │
    │                      │  [Port Opened]       │
    │                      │◀─────────────────────│
    │  [Connected]         │                      │
    │◀─────────────────────│                      │
    │                      │                      │
    │  device_Model        │                      │
    │─────────────────────▶│  [Query]             │
    │                      │─────────────────────▶│
    │                      │  [SK1-21]            │
    │  [SK1-21]            │◀─────────────────────│
    │◀─────────────────────│                      │
    │                      │                      │
```

---

## Note importante

1. **Ordinea operațiilor este critică**:
   - `startComServer()` TREBUIE apelat ÎNAINTEA oricărei alte operații
   - `set_TransportType()` și `set_RS232()`/`set_TCPIP()` TREBUIE apelate ÎNAINTEA `open_Connection()`

2. **Erori comune**:
   - Port COM ocupat de altă aplicație
   - Driver DUDE neinstalat
   - Baud rate incorect (trebuie să fie 115200 pentru SK1-21)
   - Cablu serial defect sau neconectat

3. **Implementare practică în Dart**:
   - Pentru Windows: FFI către DLL-ul DUDE sau HTTP către LDREST.exe
   - Pentru Linux/macOS: Probabil doar HTTP către un server intermediar
   - Flutter: Platform channels sau direct FFI

---

## Următorii pași

- [Comenzi de printare](./DART_PRINT_COMMANDS.md)
- [Bonuri fiscale](./FISCAL_RECEIPT_CASH.md)
- [Rapoarte](./DART_REPORTS.md)
