# %% [markdown]
# # Hands-on 1: molecules in Python
#
# AI in Material Science, University of Calicut, 24 September 2026
#
# This morning you saw that fitting a model is one matrix solve: build a feature matrix
# `A`, take the pseudoinverse, multiply by the target `y`. In this notebook the rows of
# `A` are molecules.
#
# By the end you will have:
#
# 1. turned a molecule written as text into a row of numbers,
# 2. fitted the solubility of 1128 molecules with the pseudoinverse,
# 3. improved the fit with a fingerprint and with a random forest,
# 4. predicted the solubility of a molecule you choose yourself.
#
# Run each cell with Shift+Enter. Nothing here needs the internet.

# %%
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from rdkit import Chem
from rdkit.Chem import Descriptors, Crippen, rdMolDescriptors, Draw
from rdkit import RDLogger

RDLogger.DisableLog("rdApp.*")
print("RDKit is working:", Chem.MolToSmiles(Chem.MolFromSmiles("CCO")))

# %% [markdown]
# ## 1. A molecule is a line of text
#
# SMILES writes a structure as a string. `CCO` is ethanol: carbon, carbon, oxygen.
# Letters are atoms, digits close rings, brackets hold branches.

# %%
examples = {
    "ethanol": "CCO",
    "benzene": "c1ccccc1",
    "aspirin": "CC(=O)Oc1ccccc1C(=O)O",
    "caffeine": "Cn1cnc2c1c(=O)n(C)c(=O)n2C",
    "paracetamol": "CC(=O)Nc1ccc(O)cc1",
}

mols = [Chem.MolFromSmiles(s) for s in examples.values()]
Draw.MolsToGridImage(mols, legends=list(examples), molsPerRow=5, subImgSize=(200, 160))

# %% [markdown]
# Change one of the strings above and run the cell again. If RDKit cannot read a string
# it returns `None` instead of a molecule, which is how you know the SMILES is wrong.

# %%
print("a valid SMILES  :", Chem.MolFromSmiles("CCO"))
print("a broken SMILES :", Chem.MolFromSmiles("CC(O"))

# %% [markdown]
# ## 2. From a molecule to a row of numbers
#
# A model cannot read a string. It needs numbers. The four below are the usual first
# choice: molecular weight, how greasy the molecule is (logP), how much polar surface it
# exposes (TPSA), and how many rings it has.

# %%
def descriptors(smiles):
    """Return four numbers for one SMILES string, or None if it cannot be read."""
    mol = Chem.MolFromSmiles(smiles)
    if mol is None:
        return None
    return {
        "MolWt": Descriptors.MolWt(mol),
        "LogP": Crippen.MolLogP(mol),
        "TPSA": rdMolDescriptors.CalcTPSA(mol),
        "NumRings": rdMolDescriptors.CalcNumRings(mol),
    }

for name, smi in examples.items():
    print(f"{name:12s}", descriptors(smi))

# %% [markdown]
# ## 3. The dataset
#
# 1128 molecules whose solubility in water was measured. The column `logS` is the log of
# the solubility in mol/L: a larger number means the molecule dissolves better.

# %%
df = pd.read_csv("../data/esol.csv")
print(df.shape)
df.head()

# %%
desc = df["smiles"].apply(lambda s: pd.Series(descriptors(s)))
data = pd.concat([df, desc], axis=1).dropna()
print("molecules with descriptors:", len(data))
data.head()

# %% [markdown]
# A quick look before fitting anything. Greasy molecules (high logP) dissolve badly, so
# this plot should slope downward.

# %%
fig, ax = plt.subplots(1, 2, figsize=(10, 4))
ax[0].scatter(data["LogP"], data["logS"], s=8, alpha=0.4)
ax[0].set_xlabel("LogP"); ax[0].set_ylabel("logS"); ax[0].set_title("Greasiness vs solubility")
ax[1].hist(data["logS"], bins=40)
ax[1].set_xlabel("logS"); ax[1].set_ylabel("count"); ax[1].set_title("Spread of the target")
plt.tight_layout(); plt.show()

# %% [markdown]
# ## 4. The fit, with the pseudoinverse
#
# This is this morning's mathematics, on a real chemical dataset.
#
# Each row of `A` is one molecule: a 1 for the intercept, then its four descriptors.
# The vector `y` holds the measured solubilities. The weights that minimise the squared
# error are `w = pinv(A) y`.

# %%
features = ["MolWt", "LogP", "TPSA", "NumRings"]

A = np.column_stack([np.ones(len(data))] + [data[f].values for f in features])
y = data["logS"].values

print("A is", A.shape, "and y is", y.shape)

w = np.linalg.pinv(A) @ y
print("\nweights:")
for name, weight in zip(["intercept"] + features, w):
    print(f"  {name:10s} {weight: .4f}")

# %% [markdown]
# Four numbers and an intercept, and the fit is done. No training loop, no learning rate.
#
# How good is it? `R2` is the fraction of the variation the model explains: 1.0 is
# perfect, 0.0 is no better than always predicting the average. RMSE is the typical size
# of the error, in the units of the target.

# %%
def report(y_true, y_pred, label):
    ss_res = np.sum((y_true - y_pred) ** 2)
    ss_tot = np.sum((y_true - y_true.mean()) ** 2)
    r2 = 1 - ss_res / ss_tot
    rmse = np.sqrt(ss_res / len(y_true))
    print(f"{label:28s} R2 = {r2:.3f}   RMSE = {rmse:.3f}")
    return r2, rmse

y_fit = A @ w
report(y, y_fit, "4 descriptors, pinv")

# %%
plt.figure(figsize=(5, 5))
plt.scatter(y, y_fit, s=8, alpha=0.4)
lims = [y.min() - 0.5, y.max() + 0.5]
plt.plot(lims, lims, "k--", linewidth=1)
plt.xlabel("measured logS"); plt.ylabel("predicted logS")
plt.title("Four descriptors and a pseudoinverse")
plt.tight_layout(); plt.show()

# %% [markdown]
# ## 5. Honest evaluation: hold some molecules back
#
# The fit above was scored on the same molecules it was fitted to, which flatters it.
# Split the data: fit on 80 percent, score on the 20 percent the model has never seen.

# %%
rng = np.random.default_rng(0)
order = rng.permutation(len(data))
n_train = int(0.8 * len(data))
train, test = order[:n_train], order[n_train:]

w_train = np.linalg.pinv(A[train]) @ y[train]
report(y[train], A[train] @ w_train, "4 descriptors, train")
report(y[test], A[test] @ w_train, "4 descriptors, test")

# %% [markdown]
# ## 6. Better features, same solve
#
# The four descriptors throw away most of the structure. A Morgan fingerprint records
# which small fragments appear around each atom, as a long vector of 0s and 1s.
#
# The mathematics does not change. Only the columns of `A` do.

# %%
from rdkit.Chem import rdFingerprintGenerator

gen = rdFingerprintGenerator.GetMorganGenerator(radius=2, fpSize=512)

def fingerprint(smiles):
    mol = Chem.MolFromSmiles(smiles)
    return np.array(gen.GetFingerprint(mol), dtype=float)

F = np.vstack([fingerprint(s) for s in data["smiles"]])
print("fingerprint matrix:", F.shape)

A2 = np.column_stack([A, F])
print("feature matrix now:", A2.shape)

w2 = np.linalg.pinv(A2[train]) @ y[train]
report(y[train], A2[train] @ w2, "descriptors + fp, train")
report(y[test], A2[test] @ w2, "descriptors + fp, test")

# %% [markdown]
# Look carefully at those two numbers. The training fit is the best we have seen, and the
# test result is not merely bad, it is absurd: a negative R2 with an enormous exponent.
#
# Something has broken. This is worth understanding, because it is the most common way a
# least-squares fit fails in practice.

# %%
print("largest weight in the descriptor fit :", np.abs(w_train).max())
print("largest weight in the fingerprint fit:", np.abs(w2).max())

# %% [markdown]
# ## 6b. Why it broke, and the one-line fix
#
# Recall how the pseudoinverse is built. Take the singular value decomposition of `A`,
# and the pseudoinverse **inverts each singular value**: 1/s.
#
# Look at the singular values of our fingerprint matrix.

# %%
s = np.linalg.svd(A2[train], compute_uv=False)
print("largest singular value :", f"{s.max():.3g}")
print("smallest singular value:", f"{s.min():.3g}")
print("condition number       :", f"{s.max() / s.min():.3g}")

# %% [markdown]
# Many fragments appear in almost the same set of molecules, so many columns are nearly
# copies of each other and the smallest singular values are effectively zero.
#
# Dividing by a number of size 1e-16 multiplies whatever noise sits in that direction by
# 1e16. The fit uses those directions to pass exactly through the training molecules, and
# they are meaningless for any other molecule.
#
# The fix is built into the pseudoinverse. `rcond` discards every singular value smaller
# than that fraction of the largest, so the near-empty directions are simply dropped.

# %%
for rcond in [1e-10, 1e-3, 1e-2]:
    w_try = np.linalg.pinv(A2[train], rcond=rcond) @ y[train]
    print(f"rcond = {rcond:<8g}  largest weight {np.abs(w_try).max():8.3g}   ", end="")
    report(y[test], A2[test] @ w_try, "test")

# %% [markdown]
# With the cutoff at 1e-3 the weights are sane and the model is genuinely better than the
# four descriptors alone. Keep that one.

# %%
w2 = np.linalg.pinv(A2[train], rcond=1e-3) @ y[train]
report(y[train], A2[train] @ w2, "descriptors + fp, train")
report(y[test], A2[test] @ w2, "descriptors + fp, test")
report(y[test], A[test] @ w_train, "4 descriptors, test (before)")

# %%
plt.figure(figsize=(5, 5))
plt.scatter(y[test], A2[test] @ w2, s=12, alpha=0.5)
lims = [y.min() - 0.5, y.max() + 0.5]
plt.plot(lims, lims, "k--", linewidth=1)
plt.xlabel("measured logS"); plt.ylabel("predicted logS")
plt.title("Held-out molecules, fingerprint model")
plt.tight_layout(); plt.show()

# %% [markdown]
# Two lessons, and the second is the one that keeps people out of trouble:
#
# 1. More features can help, but only if the solve is stable.
# 2. **A training score on its own tells you nothing.** The broken model above had the
#    best training score in this notebook.

# %% [markdown]
# ## 7. A different model on the same features
#
# A random forest asks a series of yes/no questions about the features. It cannot be
# solved in closed form, but it handles non-linear behaviour without being told to.

# %%
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import cross_val_score

rf = RandomForestRegressor(n_estimators=300, random_state=0, n_jobs=-1)
rf.fit(A[train, 1:], y[train])
report(y[test], rf.predict(A[test, 1:]), "4 descriptors, forest")

scores = cross_val_score(rf, A[:, 1:], y, cv=5, scoring="r2")
print("\n5-fold cross-validated R2:", np.round(scores, 3), " mean", round(scores.mean(), 3))

# %%
importance = pd.Series(rf.feature_importances_, index=features).sort_values()
importance.plot.barh(figsize=(5, 3))
plt.title("What the forest actually used"); plt.tight_layout(); plt.show()

# %% [markdown]
# ## 8. The shape of chemical space
#
# Each molecule is a point in 512-dimensional fingerprint space, which nobody can
# picture. PCA finds the two directions that carry the most variation and draws them.

# %%
from sklearn.decomposition import PCA

coords = PCA(n_components=2).fit_transform(F)

plt.figure(figsize=(6, 5))
sc = plt.scatter(coords[:, 0], coords[:, 1], c=y, s=10, cmap="viridis")
plt.colorbar(sc, label="logS")
plt.xlabel("PC 1"); plt.ylabel("PC 2"); plt.title("1128 molecules, coloured by solubility")
plt.tight_layout(); plt.show()

# %% [markdown]
# Molecules that share fragments sit near each other, and the colour changes smoothly
# across the map. That is the whole premise of the field: similar structure, similar
# property.

# %% [markdown]
# ## 9. Your own molecule
#
# Put any SMILES in the cell below. Try one from your own laboratory work.

# %%
my_smiles = "CC(=O)Nc1ccc(O)cc1"      # paracetamol

mol = Chem.MolFromSmiles(my_smiles)
if mol is None:
    print("RDKit could not read that SMILES. Check the brackets and ring digits.")
else:
    d = descriptors(my_smiles)
    row = np.concatenate([[1.0], [d[f] for f in features], fingerprint(my_smiles)])
    print(Chem.MolToSmiles(mol))
    print({k: round(v, 2) for k, v in d.items()})
    print("\npredicted logS (descriptors only):", round(float(np.concatenate([[1.0], [d[f] for f in features]]) @ w_train), 2))
    print("predicted logS (with fingerprint) :", round(float(row @ w2), 2))
    print("predicted logS (random forest)    :", round(float(rf.predict([[d[f] for f in features]])[0]), 2))

# %%
Draw.MolToImage(mol, size=(250, 200))

# %% [markdown]
# ## 10. Save the model for the next session
#
# In Hands-on 2 an AI agent will call this model as one of its tools.

# %%
np.savez("solubility_model.npz", w_train=w_train, features=np.array(features))
print("saved solubility_model.npz")

# %% [markdown]
# ## Optional: a classification problem
#
# Solubility is a number, so predicting it is regression. Toxicity is a label, so
# predicting it is classification. The dataset below comes from the CHEM 5080 course at
# Washington University and carries several targets for the same molecules.

# %%
ch = pd.read_csv("../data/ch_oxidation.csv")
print(ch.shape)
print(ch["Toxicity"].value_counts())
ch.head(3)

# %%
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, confusion_matrix

ch_desc = ch["SMILES"].apply(lambda s: pd.Series(descriptors(s)))
ch_data = pd.concat([ch, ch_desc], axis=1).dropna(subset=features + ["Toxicity"])

X = ch_data[features].values
t = (ch_data["Toxicity"] == "toxic").astype(int).values

X_tr, X_te, t_tr, t_te = train_test_split(X, t, test_size=0.25, random_state=0, stratify=t)
clf = RandomForestClassifier(n_estimators=300, random_state=0).fit(X_tr, t_tr)
pred = clf.predict(X_te)

print("accuracy:", round(accuracy_score(t_te, pred), 3))
print("confusion matrix (rows: true non-toxic, toxic):")
print(confusion_matrix(t_te, pred))

# %% [markdown]
# ## What to take away
#
# - A molecule became a row of numbers, and the choice of those numbers mattered more
#   than the choice of model.
# - The first working model was one pseudoinverse, exactly as in the morning session.
# - Scoring on molecules the model has seen is not scoring. Hold data back.
# - Everything here scales: swap solubility for band gap, toxicity for catalytic
#   activity, and the workflow is unchanged.
