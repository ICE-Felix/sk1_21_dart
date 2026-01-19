# Datecs SK1-21 - Z Report Operation

## Script

```
69,Z
```

---

## Command 69 (45h) - Reports

**Format:**
```
69,<ReportType>
```

**Parameters:**

| Parameter | Field | Description | Values |
|-----------|-------|-------------|--------|
| ReportType | Report type | Type of report | `X`, `Z`, `E`, `D`, `G` |

**Report Types:**

| Type | Name | Description |
|------|------|-------------|
| `X` | X Report | Preview - shows daily totals without closing the day |
| `Z` | Z Report | Daily closure - writes to fiscal memory, resets counters. **Can only be done once per day!** |
| `E` | ECR Report | ECR report |
| `D` | Departments Report | Report by departments |
| `G` | Item Groups Report | Report by item groups |

**Output Parameters (for X and Z reports):**

| Parameter | Description |
|-----------|-------------|
| nRep | Number of Z-report (1...2500) |
| TotA | Total sum accumulated by TAX group A |
| TotB | Total sum accumulated by TAX group B |
| TotC | Total sum accumulated by TAX group C |
| TotD | Total sum accumulated by TAX group D |
| TotE | Total sum accumulated by TAX group E |
| TotF | Total sum accumulated by TAX group F |
| TotEXEPTAT | Total sum accumulated - EXEPTAT |
| TotSInv | Total sum accumulated - simplify invoice |
| VatSInv | Total VAT accumulated - simplify invoice |

---

## Examples

**Z Report (Daily Closure):**
```
69,Z
```

**X Report (Preview Only):**
```
69,X
```

**ECR Report:**
```
69,E
```

**Departments Report:**
```
69,D
```

**Item Groups Report:**
```
69,G
```

---

## Notes

- Z Report closes the fiscal day and writes totals to fiscal memory
- All daily counters are reset to zero after Z Report
- Z Report can only be printed **once per day**
- Use X Report (type `2`) to preview daily totals without closing
