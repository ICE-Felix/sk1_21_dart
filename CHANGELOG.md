# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-01-18

### Added

#### Core Features
- `DatecsDudeDriver` - Main driver using PowerShell + DUDE COM object
- `DatecsRestDriver` - Alternative driver using LDREST.exe HTTP server
- RS232 and TCP/IP connection support

#### Fiscal Receipt Operations
- `openFiscalReceipt()` - Open fiscal receipt with operator and invoice options
- `registerSale()` - Register sale items with tax groups, discounts, surcharges
- `subtotal()` - Print subtotal with optional discount/surcharge
- `registerPayment()` - Register payments (10 payment types supported)
- `closeFiscalReceipt()` - Close and print fiscal receipt
- `cancelFiscalReceipt()` - Cancel current fiscal receipt
- `printFiscalText()` - Print text in fiscal receipt

#### Non-Fiscal Receipt Operations
- `openNonFiscalReceipt()` - Open non-fiscal receipt
- `printNonFiscalText()` - Print text lines
- `closeNonFiscalReceipt()` - Close non-fiscal receipt

#### Reports
- `generateDailyReport()` - X Report (read) and Z Report (reset)
- `printOperatorsReport()` - Print operators statistics
- `printPluReport()` - Print PLU items report
- `printFiscalReportByDates()` - Fiscal memory report by date range
- `printFiscalReportByZNumbers()` - Fiscal memory report by Z-report numbers
- `printDiagnostic()` - Print diagnostic information

#### Display Control
- `clearDisplay()` - Clear external display
- `displayUpperLine()` - Show text on upper line
- `displayLowerLine()` - Show text on lower line

#### Date/Time Operations
- `setDateTime()` - Set printer date and time
- `readDateTime()` - Read current date and time

#### VAT/Tax Operations
- `programVatRates()` - Program tax rates for groups A-H
- `readVatRates()` - Read current VAT rates

#### PLU (Price Look-Up) Operations
- `programPluItem()` - Program PLU item
- `readPluItem()` - Read PLU item by code
- `deletePluItem()` - Delete PLU item
- `sellProgrammedItem()` - Sell programmed PLU item

#### Fiscal Memory Operations
- `getRemainingZReports()` - Get remaining Z-reports capacity
- `getLastFiscalRecordDate()` - Get date of last fiscal record
- `testFiscalMemory()` - Test fiscal memory integrity
- `readFiscalMemory()` - Read fiscal memory records
- `getLastFiscalEntryInfo()` - Get last fiscal entry information

#### Electronic Journal Operations
- `getJournalInfo()` - Get journal statistics
- `searchJournalByDate()` - Search journal by date
- `searchJournalByReceipt()` - Search journal by receipt number
- `exportXmlFiles()` - Export journal to XML

#### Information Queries
- `getStatus()` - Get printer status
- `getReceiptStatus()` - Get current receipt status
- `getCurrentReceiptInfo()` - Get current receipt information
- `getDailyTaxationInfo()` - Get daily tax totals
- `getAdditionalDailyInfo()` - Get additional daily statistics
- `getDepartmentInfo()` - Get department information
- `getItemGroupInfo()` - Get item group information
- `getOperatorInfo()` - Get operator statistics
- `getDiagnosticInfo()` - Get diagnostic information
- `getDeviceFullInfo()` - Get complete device information
- `readTaxNumber()` - Read tax registration number
- `readLastError()` - Read last error description

#### Programming Operations
- `programHeaderLine()` - Program receipt header lines
- `programOperatorPassword()` - Change operator password

#### Hardware Control
- `paperFeed()` - Feed paper by lines
- `paperCut()` - Cut paper
- `ejectPaper()` - Eject paper for user
- `openCashDrawer()` - Open cash drawer
- `cashInOut()` - Cash in/out operations
- `playSound()` - Play beep sound

#### Graphics Operations
- `printBarcode()` - Print various barcode types
- `printQRCode()` - Print QR codes
- `loadLogo()` - Load logo image
- `loadStampImage()` - Load stamp image
- `printStamp()` - Print stamp

#### Printing
- `printSeparatingLine()` - Print separator line

#### Configuration
- `readParameter()` - Read configuration parameter
- `writeParameter()` - Write configuration parameter

#### Service Operations
- `fiscalize()` - Fiscalize device
- `programSerialNumber()` - Program serial number
- `switchMode()` - Switch printer mode
- `serviceOperation()` - Execute service operations

#### Models
- `SaleItem` - Sale item with name, price, quantity, tax group
- `Payment` - Payment with type and amount
- `TaxGroup` - Tax groups A-H with rates
- `PaymentType` - 10 payment types
- `ReceiptType` - Fiscal, non-fiscal, invoice types
- `PrinterStatus` - Complete printer status with all flags
- `ReceiptStatus` - Current receipt state
- `ReceiptInfo` - Receipt totals and items count
- `PluItem` - PLU item definition
- `PluSale` - PLU sale operation
- `Department` - Department data and statistics
- `ItemGroup` - Item group data
- `OperatorData` - Operator statistics
- `FiscalMemoryRecord` - Fiscal memory Z-report data
- `JournalInfo` - Electronic journal information
- `DatecsErrorCode` - Error code enumeration

### Dependencies
- `serial_port_win32: ^1.2.0` - Serial port communication
- `http: ^1.1.0` - HTTP client for REST driver
