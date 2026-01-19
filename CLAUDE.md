# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dart package for Datecs SK1-21 fiscal thermal printer. Uses PowerShell bridge to access DUDE COM driver on Windows.

## Build Commands

```bash
dart pub get      # Get dependencies
dart analyze      # Analyze code
dart format .     # Format code
```

## Architecture

### Package Structure
```
lib/
  datecs_sk1_21.dart     # Main export
  src/
    datecs_driver.dart      # Abstract driver interface
    datecs_dude_driver.dart # DUDE COM implementation (recommended)
    datecs_rest_driver.dart # HTTP REST implementation
    models/
      config.dart           # Rs232Config, TcpIpConfig, DeviceInfo
      receipt.dart          # SaleItem, Payment, TaxGroup, etc.
      reports.dart          # DailyReportType
example/
  example.dart             # Full usage example
docs/
  DATECS_COMMANDS.md       # Command reference
  DATECS_OPERATIONS.md     # Z report operations
  FISCAL_RECEIPT_*.md      # Receipt examples
```

### Key Components
1. **DatecsDudeDriver** - Main driver using PowerShell + DUDE COM object
2. **DatecsRestDriver** - Alternative using LDREST.exe HTTP server
3. **Models** - SaleItem, Payment, TaxGroup, ReceiptType, etc.

### Serial Configuration (SK1-21)
- COM port: 4 (default)
- Baud rate: 115200
- Data bits: 8, Parity: None, Stop bits: 1

### Known Limitations (SK1-21)

**Paper Presenter**: The SK1-21 does NOT support software-controlled paper presentation via the Datecs protocol. The physical "eject" button on the printer triggers a hardware-level presenter motor that is not exposed through the DUDE driver or protocol.

- `ejectPaper()` performs feed + cut only (not automatic paper presentation)
- `BackFeedSteps` parameter is only available on FP-800 and FP-650 models (per FP_Protocol_EN.pdf page 62)
- All Command 255 parameters return error -112001 on SK1-21 via DUDE driver
- There is no software command to replicate the physical button's paper ejection behavior

## Usage Example

```dart
final driver = DatecsDudeDriver();
await driver.startComServer();
await driver.openRs232Connection(Rs232Config(comPort: 4, baudRate: 115200));

// Fiscal receipt
await driver.openFiscalReceipt();
await driver.registerSale(SaleItem(name: 'Product', price: 10.0, quantity: 1, taxGroup: TaxGroup.b));
await driver.registerPayment(Payment(type: PaymentType.cash));
await driver.closeFiscalReceipt();
await driver.ejectPaper();

await driver.closeConnection();
driver.dispose();
```

## Test

```bash
dart run example/example.dart
```
