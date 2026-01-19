# Datecs SK1-21 - Bon NEFISCAL

## Script Complet

```
38
42,================================\t
42,      BON NEFISCAL\t
42,================================\t
42,\t
42,Data: 18.01.2026\t
42,Ora: 14:30\t
42,\t
42,Informatii client:\t
42,Nume: Ion Popescu\t
42,Telefon: 0721 123 456\t
42,\t
42,================================\t
39
```

---

## Secventa Comenzi

### 1. Deschidere Bon Nefiscal - Comanda 38 (26h)

**Format (per FP_Protocol_EN.pdf page 10):**
```
Syntax 1: none (no parameters)
Syntax 2: {Param}<SEP>  where Param=1 means "Don't print header lines"
```

**Exemple:**
```
38           (opens non-fiscal receipt with header)
38,1\t       (opens non-fiscal receipt WITHOUT header)
```

**Parametri:**

| Parametru | Descriere | Valoare |
|-----------|-----------|---------|
| Param | Suprima header (optional) | `1` = nu printa header, gol = printa header |

**IMPORTANT:** Comanda 38 NU necesita credentiale operator! Documentatia anterioara era incorecta.

---

### 2. Printare Text Nefiscal - Comanda 42 (2Ah)

**Format:**
```
42,<Text><SEP>
```

**Exemple:**
```
42,Aceasta este o linie de text
42,================================
42,   Text centrat
```

**Parametri:**

| Parametru | Descriere | Valoare |
|-----------|-----------|---------|
| Text | Text de printat | max 42 caractere |

**Note:**
- Latimea maxima este de 42 caractere
- Se pot folosi caractere speciale pentru formatare
- Fiecare comanda 42 printeaza o linie noua

---

### 3. Inchidere Bon Nefiscal - Comanda 39 (27h)

**Format:**
```
39
```

Aceasta comanda nu are parametri. Inchide bonul nefiscal si il printeaza.

---

## Exemple Practice

### Bon Informativ

```
38
42,================================\t
42,        INFORMATII\t
42,================================\t
42,\t
42,Program functionare:\t
42,Luni - Vineri: 08:00 - 18:00\t
42,Sambata: 09:00 - 14:00\t
42,Duminica: INCHIS\t
42,\t
42,Contact: 021 123 4567\t
42,================================\t
39
```

### Bon Garantie

```
38
42,================================\t
42,       CERTIFICAT GARANTIE\t
42,================================\t
42,\t
42,Produs: Telefon Samsung S24\t
42,Serie: IMEI123456789\t
42,Data achizitie: 18.01.2026\t
42,Garantie: 24 luni\t
42,\t
42,Termen garantie: 18.01.2028\t
42,\t
42,================================\t
42,     Pastrati acest bon!\t
42,================================\t
39
```

### Bon Parcare

```
38
42,================================\t
42,         TICHET PARCARE\t
42,================================\t
42,\t
42,Numar auto: B 123 ABC\t
42,Intrare: 18.01.2026 10:30\t
42,Loc: A-15\t
42,\t
42,Tarif: 5 LEI / ora\t
42,\t
42,================================\t
39
```

### Comanda Restaurant

```
38
42,================================\t
42,         COMANDA #125\t
42,================================\t
42,Masa: 7\t
42,Ospatar: Maria\t
42,--------------------------------\t
42,1x Pizza Margherita\t
42,2x Coca Cola 0.5L\t
42,1x Tiramisu\t
42,--------------------------------\t
42,\t
42,Ora comenzii: 13:45\t
42,================================\t
39
```

---

## Diferenta: Fiscal vs Nefiscal

| Caracteristica | Bon Fiscal | Bon Nefiscal |
|----------------|------------|--------------|
| Inregistrare fiscala | DA | NU |
| Numar unic | DA | NU |
| Continut | Produse/Preturi | Text liber |
| Utilizare | Vanzari | Informatii |
| Memoria fiscala | Se scrie | NU se scrie |
| Comenzi | 48, 49, 53, 56 | 38, 42, 39 |

---

## Note

- `<SEP>` = caracter TAB (`\t`)
- Bonul nefiscal NU se inregistreaza in memoria fiscala
- Se poate folosi pentru informatii, garantii, comenzi, etc.
- Latimea maxima: 42 caractere per linie
- Nu exista limita de linii per bon
