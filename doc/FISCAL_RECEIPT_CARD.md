# Datecs SK1-21 - Bon Fiscal cu Plata CARD

## Script Complet

```
48,1\t0001\t1\t\t\t
49,Produs Test\t2\t10.00\t1\t0\t0\t1\tbuc\t
53,1\t\t
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

### 3. Total si Plata CARD - Comanda 53 (35h)

**Format:**
```
53,<PaidMode><SEP><Amount><SEP>
```

**Exemplu (plata exacta):**
```
53,1
```

**Parametri:**

| Parametru | Descriere | Valoare |
|-----------|-----------|---------|
| PaidMode | Mod plata | `1` = CARD |
| Amount | Suma platita | gol = suma exacta |

**IMPORTANT:** `PaidMode = 1` pentru plata cu CARD

**Toate Modurile de Plata:**

| Cod | Denumire |
|-----|----------|
| `0` | NUMERAR (CASH) |
| `1` | CARD |
| `2` | CREDIT |
| `3` | TICHETE MASA |
| `4` | TICHETE VALORICE |
| `5` | VOUCHER |
| `6` | PLATA MODERNA |
| `7` | CARD + AVANS NUMERAR |
| `8` | ALTE METODE |
| `9` | VALUTA |

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
49,Laptop\t2\t2500.00\t1\t0\t0\t1\tbuc\t
49,Mouse\t2\t50.00\t1\t0\t0\t1\tbuc\t
49,Tastatura\t2\t150.00\t1\t2\t5\t1\tbuc\t
53,1\t\t
56
```

**Explicatie:**
- Deschide bon fiscal
- Vinde 1x Laptop la 2500.00
- Vinde 1x Mouse la 50.00
- Vinde 1x Tastatura la 150.00 cu 5% discount = 142.50
- Total: 2692.50 LEI
- Plata cu CARD (suma exacta)
- Inchide bonul

---

## Plata Mixta (CASH + CARD)

Pentru plata cu mai multe metode, se pot adauga mai multe comenzi 53:

```
48,1\t0001\t1\t\t\t
49,Produs\t2\t100.00\t1\t0\t0\t1\tbuc\t
53,0\t50.00\t
53,1\t\t
56
```

**Explicatie:**
- Total: 100.00 LEI
- Plata 50.00 CASH
- Rest 50.00 CARD
- Inchide bonul

---

## Note

- `<SEP>` = caracter TAB (`\t`)
- Toate preturile sunt in moneda locala (LEI)
- Bonul fiscal se inregistreaza in memoria fiscala
- La plata CARD nu exista rest (doar suma exacta)
- Fiecare bon fiscal are numar unic secvential
