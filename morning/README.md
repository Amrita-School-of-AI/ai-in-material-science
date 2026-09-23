# Morning session: nine cells to run live

**AI in Material Science, University of Calicut, 24 September 2026, 09:00 to 12:30.**

Nine short pieces of code, one for each topic of the morning, in your order. The
idea is to teach a topic, then ask the room to run the matching cell, so that
every fifteen minutes or so the participants do something themselves. Each cell
prints a few lines and draws one figure.

Every cell runs in **MATLAB and in GNU Octave**, with no toolbox. Nothing needs
the internet. The slowest cell takes about three seconds on an old laptop, and
the whole file runs top to bottom in under five.

## What to hand out

Give the participants the whole `morning` folder, on the USB stick or by email:

```
morning/
  foundations.m        the nine cells in one file
  cells/               the same nine, one file each
  data/                digits.csv and esol_selfies.csv
  README.md            this page
```

## How a participant runs one cell

| | |
|---|---|
| **MATLAB** | Open `foundations.m`. Click anywhere inside a cell and press **Ctrl+Enter**. The cell you are in is highlighted. |
| **Octave (graphical)** | Open `foundations.m` in the editor, select the lines of the cell, press **F9**. |
| **Octave (any version)** | Change to the `cells` folder and type the name at the prompt: `cell01_column_row`, then `cell02_pseudoinverse`, and so on. This always works and is the one to fall back on if anything misbehaves. |

Tell them at the start to open a terminal, change to the folder and type `pwd`,
so that nobody is hunting for the path in the middle of the session.

## The nine cells

| After you cover | Ask them to run | What appears on screen |
|---|---|---|
| Linear algebra, C&R decomposition | `cell01_column_row` | A 4 by 4 matrix of rank 2, the two independent columns it reduces to, and `R` computed as `pinv(C)*A`. It prints that `A - C*R` is 9e-16, so the identity is exact. A 3D plot shows all four columns lying on the plane spanned by the two in `C`. |
| The pseudoinverse | `cell02_pseudoinverse` | A point projected onto a line in 3D, with the dropped residual at right angles, `a'*r` printed as 3e-15. Then five points and two unknowns, with `pinv` and backslash agreeing to four decimals. |
| Linear regression | `cell03_linear_regression` | Forty noisy points from a known line. Recovers slope 2.13 against a true 2.00, R squared 0.97, with the fit drawn through the data. |
| Non-linear regression | `cell04_nonlinear_regression` | The same `pinv` on the same bent data three times: a straight line reaches R squared 0.31, powers of x reach 0.92, ten Gaussian bumps reach 0.92. Only the columns changed. |
| Pattern classification | `cell05_classification` | Two clouds of points labelled +1 and -1, fitted by least squares. 99.2% correct, with the boundary drawn where the fit crosses zero. |
| Random Fourier features | `cell06_random_fourier` | A wiggly function fitted with random cosines: 5 features give R squared 0.51, 20 give 0.90, 100 give 0.9999. The random numbers are never adjusted. |
| Random kitchen sinks | `cell07_kitchen_sink` | Two interleaved half moons. A straight line manages 87.5%, and 300 random features followed by one `pinv` reach 100%. The plane is shaded by the decision the model makes there. |
| Backpropagation-free training | `cell08_backprop_free_nn` | 1797 handwritten digits. A 600 unit hidden layer of random weights, never touched, and an output layer solved with `pinv`. **About 97 to 99% on digits the model never saw**, in three seconds. Sixteen test digits are shown with the labels it gave them. |
| SMILES and SELFIES | `cell09_smiles_selfies` | 1069 molecules. Counting characters in the SMILES and SELFIES text gives twelve numbers per molecule, and one `pinv` predicts measured solubility with **R squared about 0.70 to 0.76 on held-out molecules**. The header of the cell carries a six molecule table of SMILES against SELFIES. |

## Two things worth saying out loud

**Cell 8 is the punchline of the morning.** A neural network reaching 97% on
handwritten digits, with no gradients, no epochs and no learning rate, makes
the point better than any slide. It is worth pausing on the fact that the only
thing fitted is the last layer, and it is fitted by the same `pinv` from cell 2.

**Cell 9 hands over to the afternoon.** It ends by saying that counting
characters is a crude description of a molecule and that the afternoon replaces
the counts with proper chemical descriptors. The afternoon session opens on
exactly that point and fits the same ESOL solubility data with `pinv` again, so
the two halves of the day join up.

## If something goes wrong on the day

- **A cell errors on a missing file.** Cells 8 and 9 look for the `data` folder
  in several places. Ask the participant to change to the `morning` folder, or
  to the `cells` folder, and run it again.
- **Octave does not recognise the cell markers.** Older builds have no cell
  mode. Use the separate files in `cells/` instead.
- **A figure window does not appear.** The numbers still print, which is the
  part that matters. Carry on.
- **The numbers differ slightly from this page.** Cells 3 and 5 onwards use
  random draws with a fixed seed, and MATLAB and Octave produce different
  numbers from the same seed. The conclusions do not change, only the last
  decimals.

Tested end to end in GNU Octave 8.4.0 on 24 September 2026. Every cell runs
clean, including the figures.
