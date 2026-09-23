# Datasets bundled with the workshop

Both files are small, plain CSV, and ship on the USB stick so that nothing has to be
downloaded during the session.

## `esol.csv` (1128 molecules)

Aqueous solubility of small organic molecules. Columns: `name`, `smiles`, `logS`
(measured log solubility in mol/L), `mw_ref` (molecular weight as given in the source,
kept only so that a computed descriptor can be checked against it).

Source: Delaney, J. S. "ESOL: Estimating Aqueous Solubility Directly from Molecular
Structure." *Journal of Chemical Information and Computer Sciences* 44 (2004) 1000-1005.
Distributed with DeepChem as `delaney-processed.csv`; reduced here to four columns.

Used in Hands-on 1 as the regression target.

## `ch_oxidation.csv` (575 molecules)

C-H oxidation dataset from the CHEM 5080 course materials. Columns include `Compound
Name`, `CAS`, `SMILES`, `Solubility_mol_per_L`, `pKa`, `Toxicity`, `Melting Point`,
`Reactivity`, `Oxidation Site`.

Source: Zheng, Z. *CHEM 5080: AI for Experimental Chemistry*, Washington University in
St. Louis. Course site `zzhenglab.github.io/ai4chem`, data file
`book/_data/C_H_oxidation_dataset.csv`. The course states that all its tutorials are
free and shareable. Cite the course, and the accompanying paper: Zheng, Z. "Developing
an AI Course for Synthetic Chemistry Students", *J. Chem. Educ.* (2026).

Used in the optional tail of Hands-on 1 (toxicity classification) and as the example of
a multi-target chemical dataset.
