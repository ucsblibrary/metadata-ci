# metadata-ci

A CLI/library for validating ADRL metadata

## CLI

### CSV
```
$ bin/check test/fixtures/csv/pamss045-invalid.csv
test/fixtures/csv/pamss045-invalid.csv:
  'created_start' in row 0: 'bleb' is not W3C-valid (https://www.w3.org/TR/1998/NOTE-datetime-19980827).
test/fixtures/csv/pamss045-invalid.csv:
  'created_finish' in row 0: '1974-9' is not W3C-valid (https://www.w3.org/TR/1998/NOTE-datetime-19980827).
test/fixtures/csv/pamss045-invalid.csv:
  'created_start' in row 1: '1930-' is not W3C-valid (https://www.w3.org/TR/1998/NOTE-datetime-19980827).

$ echo $?
1

$ bin/check test/fixtures/csv/pamss045.csv

$ echo $?
0
```

### MODS
```
$ bin/check test/fixtures/mods/cusbmss228-p00001-invalid.xml
test/fixtures/mods/cusbmss228-p00001-invalid.xml:
  Value of 'long ago' for 'dateCreated' is not W3C-valid (https://www.w3.org/TR/1998/NOTE-datetime-19980827).

$ echo $?
1

$ bin/check test/fixtures/mods/cusbmss228-p00001-invalid.xml

$ echo $?
0
```
