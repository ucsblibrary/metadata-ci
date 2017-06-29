# metadata-ci

A CLI/library for validating ADRL metadata.

## Adding a new checker

To add a new checker, provide a method that accepts `ARGV` as its
parameter and returns an array of `MetadataError`s; then add it to the
array in `bin/check`.

## CLI

General usage:
```
bin/check <files>
```

### MODS
```
» bin/check test/fixtures/mods/*

* test/fixtures/mods/cusbmss228-p00001-latin1.xml:
  Missing 'encoding="UTF-8"' declaration.

* test/fixtures/mods/cusbmss228-p00001-missing-declaration.xml:
  Missing 'encoding="UTF-8"' declaration.

* test/fixtures/mods/cusbspcmss36-110001-ISO-8859-1.xml:
  Missing 'encoding="UTF-8"' declaration.

* test/fixtures/mods/cusbspcmss36-110001_utf16.xml:
  invalid byte sequence in UTF-8

* test/fixtures/mods/cusbspcmss36-110001_windows-1252.xml:
  Missing 'encoding="UTF-8"' declaration.

* test/fixtures/mods/html-entities.xml:
  HTML-encoded character '&apos;' on line 15

* test/fixtures/mods/html-entities.xml:
  HTML-encoded character '&#x27;' on line 20

* test/fixtures/mods/cusbmss228-p00001-invalid.xml:
  Value of dateCreated: 'long ago' is not W3C-valid (https://www.w3.org/TR/1998/NOTE-datetime-19980827).

» echo $?
1
```

### CSV
There’s a lot of errors in these files!!
```
» bin/check test/fixtures/csv/*

* test/fixtures/csv/mcpeak-utf8problems.csv:
  invalid byte sequence in UTF-8

* test/fixtures/csv/uarch112-part3a-excel-csv.csv:
  invalid byte sequence in UTF-8

* test/fixtures/csv/uarch112-part3a-msdos-csv.csv:
  invalid byte sequence in UTF-8

* test/fixtures/csv/uarch112-part3a-windows-csv.csv:
  invalid byte sequence in UTF-8

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&apos;' on line 3

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&in;' on line 4

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&mid;' on line 4

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&mid;' on line 4

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&Psi;' on line 4

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&Psi;' on line 4

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&Psi;' on line 4

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&rarr;' on line 4

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&#x27;' on line 5

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&#x3BB;' on line 5

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&#xE4;' on line 5

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&#xE4;' on line 5

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&#xE4;' on line 5

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&#x2013;' on line 6

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&#x394;' on line 6

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&#x2013;' on line 6

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&#x27;' on line 6

* test/fixtures/csv/html-entities.csv:
  HTML-encoded character '&#x3BB;' on line 6

* test/fixtures/csv/mcpeak-utf8problems.csv:
  invalid byte sequence in UTF-8

* test/fixtures/csv/pamss045-invalid.csv:
  created_start in row 1: 'bleb' is not W3C-valid (https://www.w3.org/TR/1998/NOTE-datetime-19980827).

* test/fixtures/csv/pamss045-invalid.csv:
  created_finish in row 1: '1974-9' is not W3C-valid (https://www.w3.org/TR/1998/NOTE-datetime-19980827).

* test/fixtures/csv/pamss045-invalid.csv:
  created_start in row 2: '1930-' is not W3C-valid (https://www.w3.org/TR/1998/NOTE-datetime-19980827).

* test/fixtures/csv/uarch112-part3a-excel-csv.csv:
  invalid byte sequence in UTF-8

* test/fixtures/csv/uarch112-part3a-msdos-csv.csv:
  invalid byte sequence in UTF-8

* test/fixtures/csv/uarch112-part3a-windows-csv.csv:
  invalid byte sequence in UTF-8

» echo $?
1
```
