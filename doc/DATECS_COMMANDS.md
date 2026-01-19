# Datecs SK1-21 Command Reference

## Receipt Commands

| Command | Description |
|---------|-------------|
| 038_receipt_NonFiscal_Open | Open non-fiscal receipt |
| 039_receipt_NonFiscal_Close | Close non-fiscal receipt |
| 044_receipt_Paper_Feed | Paper feed |
| 046_receipt_Paper_Cutting | Paper cutting |
| 048_receipt_Fiscal_Open | Open fiscal receipt |
| 048_receipt_FiscalInvoice_Open | Open fiscal invoice |
| 048_receipt_AirPortFiscal_Open | Open airport fiscal receipt |
| 049_receipt_Fiscal_Sale | Fiscal sale |
| 051_receipt_Fiscal_Subtotal | Fiscal subtotal |
| 053_receipt_Fiscal_Total | Fiscal total |
| 053_receipt_Fiscal_Total_FCurrency | Fiscal total in foreign currency |
| 056_receipt_Fiscal_Close | Close fiscal receipt |
| 058_receipt_Fiscal_ItemSale | Fiscal item sale |
| 060_receipt_Fiscal_Cancel | Cancel fiscal receipt |
| 070_receipt_CashIn_CashOut | Cash in/out operations |
| 084_receipt_Print_Barcode | Print barcode |
| 084_receipt_Print_QRBarcode | Print QR barcode |
| 042_receipt_Print_NonFiscal_Text | Print non-fiscal text |
| 054_receipt_Print_Fiscal_Text | Print fiscal text |
| 092_receipt_Print_SeparatingLine | Print separating line |
| 106_receipt_Drawer_KickOut | Kick out cash drawer |

## Receipt Settings (Command 255)

| Command | Description |
|---------|-------------|
| 255_receipt_Set_PrnQuality | Set print quality |
| 255_receipt_Get_PrnQuality | Get print quality |
| 255_receipt_Set_BarcodePrint | Set barcode print |
| 255_receipt_Get_BarcodePrint | Get barcode print |
| 255_receipt_Set_LogoPrint | Set logo print |
| 255_receipt_Get_LogoPrint | Get logo print |
| 255_receipt_Set_IntUseReceipts | Set internal use receipts |
| 255_receipt_Get_IntUseReceipts | Get internal use receipts |
| 255_receipt_Set_ForeignPrint | Set foreign print |
| 255_receipt_Get_ForeignPrint | Get foreign print |
| 255_receipt_Set_PrintColumns | Set print columns |
| 255_receipt_Get_PrintColumns | Get print columns |
| 255_receipt_Set_EmptyLineAfterTotal | Set empty line after total |
| 255_receipt_Get_EmptyLineAfterTotal | Get empty line after total |
| 255_receipt_Set_DblHeigh_totalinreg | Set double height total in register |
| 255_receipt_Get_DblHeigh_totalinreg | Get double height total in register |
| 255_receipt_Set_Bold_payments | Set bold payments |
| 255_receipt_Get_Bold_payments | Get bold payments |
| 255_receipt_Set_ItemsCount | Set items count |
| 255_receipt_Get_ItemsCount | Get items count |
| 255_receipt_Get_Header | Get header |
| 255_receipt_Set_Footer | Set footer |
| 255_receipt_Get_Footer | Get footer |
| 255_receipt_Set_AirPortLocated | Set airport located |
| 255_receipt_Get_AirPortLocated | Get airport located |

## Report Commands

| Command | Description |
|---------|-------------|
| 069_report_Daily_Closure | Daily closure (Z Report) |
| 069_report_ECR | ECR report |
| 069_report_Departments | Departments report |
| 069_report_ItemGroups | Item groups report |
| 094_report_FM_ByDates | Fiscal memory report by dates |
| 094_report_FM_ByDates_NextLine | Fiscal memory by dates (next line) |
| 095_report_FM_ByZReports | Fiscal memory report by Z reports |
| 095_report_FM_ByZReports_NextLine | Fiscal memory by Z reports (next line) |
| 105_report_Operators | Operators report |
| 111_report_PLU | PLU report |

## Display Commands

| Command | Description |
|---------|-------------|
| 033_display_Clear | Clear display |
| 035_display_LowerLine | Display lower line |
| 047_display_UpperLine | Display upper line |
| 255_display_Get_BkLight_AutoOff | Get backlight auto off |
| 255_display_Set_BkLight_AutoOff | Set backlight auto off |

## Items Commands

| Command | Description |
|---------|-------------|
| 107_items_Get_ItemsInformation | Get items information |
| 107_items_Set_Item | Set item |
| 107_items_Set_ItemQuantity | Set item quantity |
| 107_items_Del_ItemsInRange | Delete items in range |
| 107_items_Get_ItemData | Get item data |
| 107_items_Get_FirstFoundProgrammed | Get first found programmed |
| 107_items_Get_LastFoundProgrammed | Get last found programmed |
| 107_items_Get_NextProgrammed | Get next programmed |
| 107_items_Get_FirstFoundWithSales | Get first found with sales |
| 107_items_Get_LastFoundWithSales | Get last found with sales |
| 107_items_Get_NextFoundWithSales | Get next found with sales |
| 107_items_Get_FirstNotProgrammed | Get first not programmed |
| 107_items_Get_LastNotProgrammed | Get last not programmed |
| 255_items_Set_ItemGroups_name | Set item groups name |
| 255_items_Get_ItemGroups_name | Get item groups name |

## Electronic Journal Commands

| Command | Description |
|---------|-------------|
| 124_ej_Search_Documents_ByDate | Search documents by date |
| 125_ej_Set_Document_For_Reading | Set document for reading |
| 125_ej_Get_LineAsText | Get line as text |
| 125_ej_Get_LineAsData | Get line as data |
| 125_ej_Print_Document | Print document |
| 125_ej_Set_LOGFiles_For_Reading | Set LOG files for reading |
| 125_ej_Get_LiineFromLOGFile | Get line from LOG file |
| 125_ej_Print_LogFiles | Print log files |
| 125_ej_Set_EJFiles_For_Reading | Set EJ files for reading |
| 125_ej_Get_LiineFrom_EJFile | Get line from EJ file |

## Info Commands

| Command | Description |
|---------|-------------|
| 043_info_Get_HeaderLines | Get header lines |
| 043_info_Get_HeaderLines_Buffer | Get header lines buffer |
| 043_info_Get_HeaderLines_RecordData | Get header lines record data |
| 045_info_Get_ModeConnectionWithPC | Get mode connection with PC |
| 050_info_Get_ActiveTaxRates | Get active tax rates |
| 062_info_Get_DateTime | Get date/time |
| 064_info_Get_LastFiscEntry | Get last fiscal entry |
| 065_info_Get_DailyTaxation | Get daily taxation |
| 068_info_Get_Remaining_ZReportEntries | Get remaining Z report entries |
| 071_info_Print_Diagnostic | Print diagnostic |
| 074_info_Get_Status | Get status |
| 076_info_Get_FiscalTransaction | Get fiscal transaction |
| 086_info_Get_LastFiscalRecord_Date | Get last fiscal record date |
| 087_info_Get_ItemGroup | Get item group |
| 088_info_Get_Department | Get department |
| 090_info_Get_Diagnostic | Get diagnostic |
| 099_info_Get_TaxNumber | Get tax number |
| 100_info_Get_Error | Get error |
| 103_info_Get_CurrentReceipt | Get current receipt |
| 110_info_Get_Daily_Payments | Get daily payments |
| 110_info_Get_Daily_NumAndSumsOfSells | Get daily number and sums of sells |
| 110_info_Get_Daily_NumAndSumsOfDiscounts | Get daily number and sums of discounts |
| 110_info_Get_Daily_NumAndSumsOfCorrections | Get daily number and sums of corrections |
| 110_info_Get_Daily_CashInCashOut | Get daily cash in/out |
| 112_info_Get_Operator | Get operator |
| 123_info_Get_Device | Get device |
| 123_info_Get_Last_FiscalReceipt | Get last fiscal receipt |

## Info Settings (Command 255)

| Command | Description |
|---------|-------------|
| 255_info_Get_FpComBaudRate | Get FP COM baud rate |
| 255_info_Get_BthEnable | Get Bluetooth enable |
| 255_info_Get_BthDiscoverability | Get Bluetooth discoverability |
| 255_info_Get_BthPairing | Get Bluetooth pairing |
| 255_info_Get_BthPinCode | Get Bluetooth PIN code |
| 255_info_Get_BthVersion | Get Bluetooth version |
| 255_info_Get_BthAddress | Get Bluetooth address |
| 255_info_Get_BarCodeHeight | Get barcode height |
| 255_info_Get_BarcodeName | Get barcode name |
| 255_info_Get_AutoPaperCutting | Get auto paper cutting |
| 255_info_Get_PaperCuttingType | Get paper cutting type |
| 255_info_Get_TimeOutBeforePrintFlush | Get timeout before print flush |
| 255_info_Get_NetInterfaceToUse | Get net interface to use |
| 255_info_Get_MainInterfaceType | Get main interface type |
| 255_info_Get_FlushAtEndOnly | Get flush at end only |
| 255_info_Get_Line_spacing | Get line spacing |
| 255_info_Get_EcrLogNumber | Get ECR log number |
| 255_info_Get_EcrAskForPassword | Get ECR ask for password |
| 255_info_Get_EcrAskForVoidPassword | Get ECR ask for void password |
| 255_info_Get_EcrSafeOpening | Get ECR safe opening |
| 255_info_Get_EcrConnectedOperReport | Get ECR connected operator report |
| 255_info_Get_EcrConnectedGroupsReport | Get ECR connected groups report |
| 255_info_Get_EcrConnectedDeptReport | Get ECR connected department report |
| 255_info_Get_EcrConnectedPluSalesReport | Get ECR connected PLU sales report |
| 255_info_Get_EcrConnectedCashReport | Get ECR connected cash report |
| 255_info_Get_EcrLogReport | Get ECR log report |
| 255_info_Get_EcrPluDailyClearing | Get ECR PLU daily clearing |
| 255_info_Get_EcrNumberBarcode | Get ECR number barcode |
| 255_info_Get_EcrOnlyAdminOpenShift | Get ECR only admin open shift |
| 255_info_Get_EcrScaleBarMask | Get ECR scale bar mask |
| 255_info_Get_AutoPowerOff | Get auto power off |
| 255_info_Get_EcrMode | Get ECR mode |
| 255_info_Get_CurrNameLocal | Get local currency name |
| 255_info_Get_CurrNameForeign | Get foreign currency name |
| 255_info_Get_ExchangeRate | Get exchange rate |
| 255_info_Get_Unit_name | Get unit name |
| 255_info_Get_OperName | Get operator name |
| 255_info_Get_OperPasw | Get operator password |
| 255_info_Get_Dept_name | Get department name |
| 255_info_Get_Payment_forbidden | Get payment forbidden |
| 255_info_Get_PayNamePgmbl | Get programmable payment name |
| 255_info_Get_ServMessage | Get service message |
| 255_info_Get_ServiceDate | Get service date |
| 255_info_Get_IMEI | Get IMEI |
| 255_info_Get_APN | Get APN |
| 255_info_Get_APN_User | Get APN user |
| 255_info_Get_APN_Pass | Get APN password |
| 255_info_Get_SimPin | Get SIM PIN |
| 255_info_Get_SimICCID | Get SIM ICCID |
| 255_info_Get_SimIMSI | Get SIM IMSI |
| 255_info_Get_SimTelNumber | Get SIM telephone number |
| 255_info_Get_LanMAC | Get LAN MAC |
| 255_info_Get_DHCPenable | Get DHCP enable |
| 255_info_Get_LAN_IP | Get LAN IP |
| 255_info_Get_LAN_NetMask | Get LAN net mask |
| 255_info_Get_LAN_Gateway | Get LAN gateway |
| 255_info_Get_LAN_PriDNS | Get LAN primary DNS |
| 255_info_Get_LAN_SecDNS | Get LAN secondary DNS |
| 255_info_Get_LANport_fpCommands | Get LAN port FP commands |
| 255_info_Get_nZreport | Get Z report number |
| 255_info_Get_nReset | Get reset number |
| 255_info_Get_nVatChanges | Get VAT changes number |
| 255_info_Get_nIDnumberChanges | Get ID number changes |
| 255_info_Get_nFMnumberChanges | Get FM number changes |
| 255_info_Get_nTAXnumberChanges | Get TAX number changes |
| 255_info_Get_nHeaderChanges | Get header changes number |
| 255_info_Get_valVat | Get VAT value |
| 255_info_Get_IDnumber | Get ID number |
| 255_info_Get_FMnumber | Get FM number |
| 255_info_Get_TAXnumber | Get TAX number |
| 255_info_Get_UserIsVatRegistered | Get user is VAT registered |
| 255_info_Get_FmWriteDateTime | Get FM write date/time |
| 255_info_Get_LastValiddate | Get last valid date |
| 255_info_Get_Fiscalized | Get fiscalized status |
| 255_info_Get_DFR_needed | Get DFR needed |
| 255_info_Get_nBon | Get receipt number |
| 255_info_Get_nFBon | Get fiscal receipt number |
| 255_info_Get_nFBonDailyCount | Get fiscal receipt daily count |
| 255_info_Get_nRBonDailyCount | Get return receipt daily count |
| 255_info_Get_Block24h | Get 24h block status |
| 255_info_Get_CurrClerk | Get current clerk |
| 255_info_Get_EJNumber | Get EJ number |
| 255_info_Get_ProfileType | Get profile type |
| 255_info_Get_Profile_startDate | Get profile start date |
| 255_info_Get_Profile_endDate | Get profile end date |
| 255_info_Get_DecimalPoint | Get decimal point |

## Configuration Commands

| Command | Description |
|---------|-------------|
| 043_config_Set_HeaderLines_FM | Set header lines (fiscal memory) |
| 043_config_Set_HeaderLines_Buffer | Set header lines buffer |
| 061_config_Set_DateTime | Set date/time |
| 101_config_Set_OperatorPassword | Set operator password |

## Configuration Settings (Command 255)

| Command | Description |
|---------|-------------|
| 255_config_Set_other_text | Set other text |
| 255_config_Set_FpComBaudRate | Set FP COM baud rate |
| 255_config_Set_BthEnable | Set Bluetooth enable |
| 255_config_Set_BthDiscoverability | Set Bluetooth discoverability |
| 255_config_Set_BthPairing | Set Bluetooth pairing |
| 255_config_Set_BthPinCode | Set Bluetooth PIN code |
| 255_config_Set_BthVersion | Set Bluetooth version |
| 255_config_Set_BthAddress | Set Bluetooth address |
| 255_config_Set_BarCodeHeight | Set barcode height |
| 255_config_Set_BarcodeName | Set barcode name |
| 255_config_Set_AutoPaperCutting | Set auto paper cutting |
| 255_config_Set_BackFeedSteps | Set back feed steps |
| 255_config_Set_PaperCuttingType | Set paper cutting type |
| 255_config_Set_TimeOutBeforePrintFlush | Set timeout before print flush |
| 255_config_Set_NetInterfaceToUse | Set net interface to use |
| 255_config_Set_MainInterfaceType | Set main interface type |
| 255_config_Set_FlushAtEndOnly | Set flush at end only |
| 255_config_Set_Line_spacing | Set line spacing |
| 255_config_Set_EcrLogNumber | Set ECR log number |
| 255_config_Set_EcrAskForPassword | Set ECR ask for password |
| 255_config_Set_EcrAskForVoidPassword | Set ECR ask for void password |
| 255_config_Set_EcrSafeOpening | Set ECR safe opening |
| 255_config_Set_EcrConnectedOperReport | Set ECR connected operator report |
| 255_config_Set_EcrConnectedGroupsReport | Set ECR connected groups report |
| 255_config_Set_EcrConnectedDeptReport | Set ECR connected department report |
| 255_config_Set_EcrConnectedPluSalesReport | Set ECR connected PLU sales report |
| 255_config_Set_EcrConnectedCashReport | Set ECR connected cash report |
| 255_config_Set_EcrLogReport | Set ECR log report |
| 255_config_Set_EcrPluDailyClearing | Set ECR PLU daily clearing |
| 255_config_Set_EcrNumberBarcode | Set ECR number barcode |
| 255_config_Set_EcrOnlyAdminOpenShift | Set ECR only admin open shift |
| 255_config_Set_EcrScaleBarMask | Set ECR scale bar mask |
| 255_config_Set_AutoPowerOff | Set auto power off |
| 255_config_Set_CurrNameLocal | Set local currency name |
| 255_config_Set_CurrNameForeign | Set foreign currency name |
| 255_config_Set_ExchangeRate | Set exchange rate |
| 255_config_Set_Unit_name | Set unit name |
| 255_config_Set_OperName | Set operator name |
| 255_config_Set_OperPasw | Set operator password |
| 255_config_Set_Dept_name | Set department name |
| 255_config_Set_Payment_forbidden | Set payment forbidden |
| 255_config_Set_PayNamePgmbl | Set programmable payment name |
| 255_config_Set_ServMessage | Set service message |
| 255_config_Set_ServiceDate | Set service date |
| 255_config_Set_LanMAC | Set LAN MAC |
| 255_config_Set_DHCPenable | Set DHCP enable |
| 255_config_Set_LAN_IP | Set LAN IP |
| 255_config_Set_LAN_NetMask | Set LAN net mask |
| 255_config_Set_LAN_Gateway | Set LAN gateway |
| 255_config_Set_LAN_PriDNS | Set LAN primary DNS |
| 255_config_Set_LAN_SecDNS | Set LAN secondary DNS |

## Other Commands

| Command | Description |
|---------|-------------|
| 080_other_VoiceSignal | Voice signal |
| 127_other_Stamp_Operations | Stamp operations |
| 149_other_Switching_Modes | Switching modes |

## Service Commands

| Command | Description |
|---------|-------------|
| 072_service_Fiscalization | Fiscalization |
| 083_service_Set_VATRates | Set VAT rates |
| 089_service_FiscalMemoryTest | Fiscal memory test |
| 091_service_Set_SerialNumber | Set serial number |
| 101_service_Set_OperatorPassword_Jumper | Set operator password (jumper) |
| 116_service_Get_FiscalMemory | Get fiscal memory |
| 253_service_Operations | Service operations |
| 253_service_Set_Password | Set service password |

---

## Example: Fiscal Receipt Sequence

```
48,1\t0001\t1\t\t\t                           # Open fiscal receipt
49,Oranges\t2\t0.01\t2.543\t2\t22.25\t0\tkg\t  # Sale item
53,0\t\t                                       # Total (cash payment)
56                                             # Close fiscal receipt
```

### Command 48 - Open Fiscal Receipt
Format: `48,<type>\t<operator>\t<password>\t<tillNumber>\t<invoice>\t`
- type: 1 = fiscal receipt
- operator: operator number (e.g., 0001)
- password: operator password (e.g., 1)

### Command 49 - Fiscal Sale
Format: `49,<name>\t<taxGroup>\t<price>\t<quantity>\t<discountType>\t<discountValue>\t<department>\t<unit>\t`
- name: item name
- taxGroup: tax group (1-8)
- price: unit price
- quantity: quantity sold
- discountType: 0=none, 1=surcharge%, 2=discount%, 3=surcharge value, 4=discount value
- discountValue: discount/surcharge value
- department: department number
- unit: unit of measure

### Command 53 - Fiscal Total
Format: `53,<paymentType>\t<amount>\t`
- paymentType: 0=cash, 1=card, 2=check, etc.
- amount: payment amount (empty for exact amount)

### Command 56 - Close Fiscal Receipt
Format: `56`
