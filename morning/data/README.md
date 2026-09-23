# Data for the morning session

Two files, both plain numeric or plain text CSV so that Octave and MATLAB read
them with `csvread` or with `fopen` and `fgetl`. No toolbox is needed.

## `digits.csv` (cell 8)

1797 rows, 65 columns, no header. The first 64 columns are the pixels of an
eight by eight greyscale image, values 0 to 16, read row by row. Column 65 is
the digit shown, 0 to 9.

Source: the optical recognition of handwritten digits dataset, collected by
E. Alpaydin and C. Kaynak, held at the UCI Machine Learning Repository and
distributed with scikit-learn as `load_digits`. Copied here unchanged, in
scikit-learn's own column order.

## `esol_selfies.csv` (cell 9)

1069 rows plus a header line. Four columns: `name`, `smiles`, `selfies`,
`logS`. The last is the measured aqueous solubility, as log of mol per litre.

Built from the ESOL set of Delaney (*J. Chem. Inf. Comput. Sci.* 44, 2004,
1000 to 1005), the same 1128 molecules used in the afternoon notebooks. The
SELFIES column was generated with the `selfies` package, version 2.2.0
(Krenn and co-workers). 59 of the 1128 molecules were dropped because the
encoder does not cover them, which leaves 1069.

Commas were removed from the compound names so that every line splits cleanly
on the comma with no quoting rules to worry about. No field in the file
contains a comma, so `strsplit(line, ',')` always returns exactly four parts.
