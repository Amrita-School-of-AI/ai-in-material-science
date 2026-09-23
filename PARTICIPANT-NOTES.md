# AI in Material Science: workshop material

University of Calicut, 24 September 2026. Amrita School of Artificial Intelligence.

Everything you need for the afternoon session is in this folder. Copy the whole folder
from the USB stick to your own machine before you start.

## What is here

| Folder | What it holds |
|---|---|
| `notebooks/` | The two notebooks you run: Hands-on 1 and Hands-on 2. |
| `data/` | The datasets, bundled so nothing downloads during the session. |
| `deck/build/` | The slides, if you want them afterwards. |
| `handout/build/` | The reading list. |
| `morning/` | Prof. Soman's MATLAB and Octave cells from the morning session. |

## Running the notebooks

Open a terminal, go to the folder you copied, and activate the environment you built
before the workshop:

```
cd ~/ai-materials
source .venv/bin/activate
jupyter lab
```

Then open `notebooks/01-molecules-in-python.ipynb` and run the cells from the top with
Shift+Enter.

If you prefer an editor, open the folder in VS Code and run the notebook there. The
`.py` file beside each notebook is the same code as a plain script, for anyone who would
rather not use a notebook at all.

## If your environment is not ready

Run this once, in the folder you copied:

```
curl -LsSf https://astral.sh/uv/install.sh | sh
uv venv --python 3.12 && source .venv/bin/activate
uv pip install rdkit pandas scikit-learn matplotlib jupyter ase
uv pip install langchain langchain-google-genai langchain-groq langgraph
```

Hands-on 1 needs only the first install line. Hands-on 2 needs both, plus your free API
key.

## Your API key (Hands-on 2 only)

Create a file called `.env` in the folder you copied, holding one line:

```
GEMINI_API_KEY=your-key-here
```

Use `GROQ_API_KEY=` instead if you made a Groq key. The notebook reads this file. Do not
share the key or commit it anywhere.

## Afterwards

The notebooks are yours to keep and change. The obvious next step is to replace
`data/esol.csv` with a dataset from your own laboratory: any CSV with a column of SMILES
and a column of measurements will work, and only the column names in section 3 of
Hands-on 1 need to change.

Everything here is also online at `github.com/Amrita-School-of-AI/ai-in-material-science`, so you can clone it later or send the link to someone who missed the day.

Questions later: `a_abhijith@cb.amrita.edu`
