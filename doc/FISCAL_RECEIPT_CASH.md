# Datecs SK1-21 - Bon Fiscal cu Plata CASH

## Script Complet

```
48,1\t0001\t1\t\t\t
49,Produs Test\t2\t10.00\t1\t0\t0\t1\tbuc\t
53,0\t\t
56
```

---

## Secventa Comenzi

### 1. Deschidere Bon Fiscal - Comanda 48 (30h)

**Format:**
```
48,<OpCode><SEP><OpPwd><SEP><TillNmb><SEP><Invoice><SEP><ClientTAXN><SEP>
```

**Exemplu:**
```
48,1\t0001\t1\t\t\t
```

**Parametri:**

| Parametru | Descriere | Valoare |
|-----------|-----------|---------|
| OpCode | Cod operator | `1` (operator 1) |
| OpPwd | Parola operator | `0001` |
| TillNmb | Numar casa | `1` |
| Invoice | Factura (optional) | gol |
| ClientTAXN | CUI client (optional) | gol |

---

### 2. Inregistrare Vanzare - Comanda 49 (31h)

**Format:**
```
49,<PluName><SEP><TaxCd><SEP><Price><SEP><Quantity><SEP><DiscountType><SEP><DiscountValue><SEP><Department><SEP><Unit><SEP>
```

**Exemplu:**
```
49,Produs Test\t2\t10.00\t1\t0\t0\t1\tbuc\t
```

**Parametri:**

| Parametru | Descriere | Valoare |
|-----------|-----------|---------|
| PluName | Denumire produs | `Produs Test` |
| TaxCd | Grupa TVA (1-8) | `2` (19% TVA) |
| Price | Pret unitar | `10.00` |
| Quantity | Cantitate | `1` |
| DiscountType | Tip discount | `0` (fara discount) |
| DiscountValue | Valoare discount | `0` |
| Department | Departament | `1` |
| Unit | Unitate masura | `buc` |

**Tipuri Discount:**

| Cod | Descriere |
|-----|-----------|
| `0` | Fara discount |
| `1` | Adaos procentual |
| `2` | Discount procentual |
| `3` | Adaos valoric |
| `4` | Discount valoric |

**Grupe TVA:**

| Cod | Denumire | Cota |
|-----|----------|------|
| `1` | A | 0% |
| `2` | B | 19% |
| `3` | C | 9% |
| `4` | D | 5% |

---

### 3. Total si Plata CASH - Comanda 53 (35h)

**Format:**
```
53,<PaidMode><SEP><Amount><SEP>
```

**Exemplu (plata exacta):**
```
53,0
```

**Exemplu (cu rest):**
```
53,0\t20.00\t
```

**Parametri:**

| Parametru | Descriere | Valoare |
|-----------|-----------|---------|
| PaidMode | Mod plata | `0` = NUMERAR (CASH) |
| Amount | Suma platita | gol = suma exacta |

**IMPORTANT:** `PaidMode = 0` pentru plata CASH (NUMERAR)

---

### 4. Inchidere Bon Fiscal - Comanda 56 (38h)

**Format:**
```
56
```

Aceasta comanda nu are parametri. Inchide bonul fiscal si il printeaza.

---

## Exemplu Complet - Mai Multe Produse

```
48,1\t0001\t1\t\t\t
49,Paine\t2\t3.50\t2\t0\t0\t1\tbuc\t
49,Lapte\t2\t6.00\t1\t0\t0\t1\tlitru\t
49,Unt\t2\t12.00\t1\t2\t10\t1\tbuc\t
53,0\t30.00\t
56
```

**Explicatie:**
- Deschide bon fiscal
- Vinde 2x Paine la 3.50 = 7.00
- Vinde 1x Lapte la 6.00 = 6.00
- Vinde 1x Unt la 12.00 cu 10% discount = 10.80
- Total: 23.80 LEI
- Plata CASH 30.00 (rest 6.20)
- Inchide bonul

---

## Note

- `<SEP>` = caracter TAB (`\t`)
- Toate preturile sunt in moneda locala (LEI)
- Bonul fiscal se inregistreaza in memoria fiscala
- Fiecare bon fiscal are numar unic secvential
