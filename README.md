# datecs_sk1_21

[![pub package](https://img.shields.io/pub/v/datecs_sk1_21.svg)](https://pub.dev/packages/datecs_sk1_21)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Complete Dart SDK for **Datecs SK1-21** fiscal thermal printer. Supports fiscal receipts, reports, PLU items, VAT rates, electronic journal, fiscal memory, and display control.

## Features

- ✅ **Fiscal Receipts** - Full fiscal receipt workflow with sales, discounts, payments
- ✅ **Non-Fiscal Receipts** - Free-form text printing
- ✅ **Daily Reports** - X Report (read-only) and Z Report (with reset)
- ✅ **PLU Management** - Program, read, delete, and sell PLU items
- ✅ **VAT/Tax Rates** - Program and read tax rates for groups A-H
- ✅ **Fiscal Memory** - Read records, test integrity, generate reports
- ✅ **Electronic Journal** - Search, read, export to XML
- ✅ **Display Control** - External customer display support
- ✅ **Cash Drawer** - Open drawer, cash in/out operations
- ✅ **Barcodes & QR** - Print various barcode types and QR codes
- ✅ **Graphics** - Logo and stamp image support
- ✅ **70+ Methods** - Complete coverage of printer commands

## Requirements

- **Windows** with DUDE COM driver installed (provided by Datecs)
- Datecs SK1-21 connected via **RS232** (USB-Serial adapter) or **TCP/IP**
- **PowerShell** (used as bridge to COM object)

## Installation

```yaml
dependencies:
  datecs_sk1_21: ^0.1.0
```

Or for local development:

```yaml
dependencies:
  datecs_sk1_21:
    path: ../datecs_sk1_21
```

## Quick Start

```dart
import 'package:datecs_sk1_21/datecs_sk1_21.dart';

void main() async {
  final driver = DatecsDudeDriver();

  // Connect
  await driver.startComServer();
  await driver.openRs232Connection(
    const Rs232Config(comPort: 4, baudRate: 115200),
  );

  // Print fiscal receipt
  await driver.openFiscalReceipt();
  await driver.registerSale(
    const SaleItem(
      name: 'Product',
      price: 10.50,
      quantity: 2,
      taxGroup: TaxGroup.b,
    ),
  );
  await driver.registerPayment(const Payment(type: PaymentType.cash));
  await driver.closeFiscalReceipt();
  await driver.ejectPaper();

  // Cleanup
  await driver.closeConnection();
  driver.dispose();
}
```

## API Reference

### Connection

| Method | Description |
|--------|-------------|
| `startComServer()` | Initialize DUDE COM server |
| `openRs232Connection(Rs232Config)` | Connect via serial port |
| `openTcpConnection(TcpIpConfig)` | Connect via TCP/IP |
| `closeConnection()` | Close connection |
| `checkConnection()` | Verify printer is responsive |
| `dispose()` | Cleanup resources |

### Fiscal Receipts

| Method | Description |
|--------|-------------|
| `openFiscalReceipt()` | Start fiscal receipt |
| `registerSale(SaleItem)` | Add product to receipt |
| `subtotal()` | Print subtotal line |
| `registerPayment(Payment)` | Register payment |
| `closeFiscalReceipt()` | Close and print receipt |
| `cancelFiscalReceipt()` | Cancel current receipt |
| `printFiscalText(String)` | Print text in receipt |

### Non-Fiscal Receipts

| Method | Description |
|--------|-------------|
| `openNonFiscalReceipt()` | Start non-fiscal receipt |
| `printNonFiscalText(String)` | Print text line |
| `closeNonFiscalReceipt()` | Close receipt |

### Reports

| Method | Description |
|--------|-------------|
| `generateDailyReport(DailyReportType.xReport)` | X Report (no reset) |
| `generateDailyReport(DailyReportType.zReport)` | Z Report (with reset) |
| `printOperatorsReport()` | Operators statistics |
| `printPluReport(start, end)` | PLU items report |
| `printFiscalReportByDates(start, end)` | FM report by dates |
| `printFiscalReportByZNumbers(startZ, endZ)` | FM report by Z numbers |
| `printDiagnostic()` | Diagnostic information |

### PLU (Price Look-Up)

| Method | Description |
|--------|-------------|
| `programPluItem(PluItem)` | Program PLU item |
| `readPluItem(code)` | Read PLU by code |
| `deletePluItem(code)` | Delete PLU item |
| `sellProgrammedItem(code, qty)` | Sell PLU item |

### VAT/Tax Rates

| Method | Description |
|--------|-------------|
| `programVatRates(Map<TaxGroup, double>)` | Set tax rates |
| `readVatRates()` | Get current rates |

### Date/Time

| Method | Description |
|--------|-------------|
| `setDateTime(DateTime)` | Set printer date/time |
| `readDateTime()` | Read current date/time |

### Fiscal Memory

| Method | Description |
|--------|-------------|
| `getRemainingZReports()` | Get remaining Z capacity |
| `getLastFiscalRecordDate()` | Last record date |
| `testFiscalMemory()` | Test FM integrity |
| `readFiscalMemory(startZ, endZ)` | Read FM records |
| `getLastFiscalEntryInfo()` | Last entry details |

### Electronic Journal

| Method | Description |
|--------|-------------|
| `getJournalInfo()` | Journal statistics |
| `searchJournalByDate(DateTime)` | Search by date |
| `searchJournalByReceipt(number)` | Search by receipt |
| `exportXmlFiles(XmlExportConfig)` | Export to XML |

### Information

| Method | Description |
|--------|-------------|
| `getStatus()` | Printer status bytes |
| `getReceiptStatus()` | Current receipt status |
| `getCurrentReceiptInfo()` | Receipt totals |
| `getDailyTaxationInfo()` | Daily tax totals |
| `getAdditionalDailyInfo()` | Cash drawer info |
| `getDepartmentInfo(dept)` | Department stats |
| `getItemGroupInfo(group)` | Item group stats |
| `getOperatorInfo(number)` | Operator stats |
| `getDiagnosticInfo()` | Device diagnostics |
| `getDeviceFullInfo()` | Complete device info |
| `readTaxNumber()` | Tax registration number |
| `readLastError()` | Last error message |

### Display

| Method | Description |
|--------|-------------|
| `clearDisplay()` | Clear display |
| `displayUpperLine(text)` | Show on upper line |
| `displayLowerLine(text)` | Show on lower line |

### Hardware Control

| Method | Description |
|--------|-------------|
| `paperFeed(lines)` | Feed paper |
| `paperCut()` | Cut paper |
| `ejectPaper()` | Eject paper |
| `openCashDrawer()` | Open drawer |
| `cashInOut(amount)` | Cash in/out |
| `playSound(freq, duration)` | Play beep |

### Barcodes & Graphics

| Method | Description |
|--------|-------------|
| `printBarcode(type, data)` | Print barcode |
| `printQRCode(data, size)` | Print QR code |
| `loadLogo(imageData)` | Load logo |
| `loadStampImage(pos, data)` | Load stamp |
| `printStamp(position)` | Print stamp |

### Configuration

| Method | Description |
|--------|-------------|
| `programHeaderLine(line, text)` | Set header line |
| `programOperatorPassword(...)` | Change password |
| `readParameter(number)` | Read parameter |
| `writeParameter(number, value)` | Write parameter |

## Models

### SaleItem

```dart
SaleItem(
  name: 'Product Name',        // Required: item name
  price: 10.50,                // Required: unit price
  quantity: 2,                 // Default: 1.0
  taxGroup: TaxGroup.b,        // Default: TaxGroup.b (19%)
  unit: 'pcs',                 // Default: 'pcs'
  discountType: DiscountType.none,
  discountValue: 0.0,
)
```

### Payment

```dart
Payment(
  type: PaymentType.cash,      // Required: payment type
  amount: 0,                   // 0 = exact amount
)
```

### TaxGroup

| Group | Default Rate | Description |
|-------|--------------|-------------|
| `TaxGroup.a` | 0% | Tax exempt |
| `TaxGroup.b` | 19% | Standard rate |
| `TaxGroup.c` | 9% | Reduced rate |
| `TaxGroup.d` | 5% | Reduced rate |
| `TaxGroup.e` - `TaxGroup.h` | Custom | Configurable |

### PaymentType

| Type | Code | Description |
|------|------|-------------|
| `cash` | 0 | Cash payment |
| `card` | 1 | Card payment |
| `credit` | 2 | Credit |
| `check` | 3 | Check |
| `voucher` | 4 | Voucher |
| `packaging` | 5 | Packaging |
| `service` | 6 | Service |
| `damage` | 7 | Damage |
| `catering` | 8 | Catering |
| `rounding` | 9 | Rounding |

## Driver

### DatecsDudeDriver

Uses PowerShell to communicate with DUDE COM object directly:

```dart
final driver = DatecsDudeDriver();
await driver.startComServer();
await driver.openRs232Connection(config);
```

## Known Limitations (SK1-21)

**Paper Presenter**: The SK1-21 does NOT support software-controlled paper presentation. The physical "eject" button triggers a hardware presenter motor not exposed via protocol.

- `ejectPaper()` performs feed + cut only (not automatic paper presentation)
- `BackFeedSteps` parameter is only available on FP-800/FP-650 models

## Serial Configuration

Default settings for SK1-21:

| Parameter | Value |
|-----------|-------|
| COM Port | 4 (varies) |
| Baud Rate | 115200 |
| Data Bits | 8 |
| Parity | None |
| Stop Bits | 1 |

## Documentation

See the `doc/` folder for:
- [DATECS_COMMANDS.md](doc/DATECS_COMMANDS.md) - Complete command reference
- [DATECS_OPERATIONS.md](doc/DATECS_OPERATIONS.md) - Z Report operations
- Fiscal receipt examples

## License

MIT License - see [LICENSE](LICENSE) file.

## Author

Alex Bordei - Senior Software Engineer at [ICEFelix](https://icefelix.com)
