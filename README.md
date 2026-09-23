# AI in Material Science

A one-day hands-on workshop for students with no machine-learning background, delivered
by the **Amrita School of Artificial Intelligence**, Amrita Vishwa Vidyapeetham,
Coimbatore.

First run: University of Calicut, 24 September 2026.

Everything here is meant to be re-run. Clone it, work through the two notebooks, and
change the dataset to something from your own laboratory.

## What the day covers

**Morning.** Foundations, from linear algebra to learning: the column-row decomposition,
the pseudoinverse, linear and non-linear regression, pattern classification, random
Fourier features, random kitchen sinks, and training a neural network without
backpropagation. Worked in MATLAB, and every script also runs in GNU Octave.
Delivered by **Prof. K. P. Soman**.

**Afternoon.** What machine learning is doing in chemistry and materials today, then two
hands-on sessions in Python. Delivered by **Dr. Abhijith Anandakrishnan**.

## Start here

| You want to | Open |
|---|---|
| Run the first exercise | `notebooks/01-molecules-in-python.ipynb` |
| Run the agent exercise | `notebooks/02-agent-that-does-chemistry.ipynb` |
| Follow the morning session | `morning/README.md` |
| See the slides | `slides/afternoon.pdf` |
| Read further | `handout/reading-list.pdf` |

## Setting up

You need Python 3.11 or later on Linux or macOS. On Windows, use WSL 2.

```bash
git clone https://github.com/Amrita-School-of-AI/ai-in-material-science.git
cd ai-in-material-science

curl -LsSf https://astral.sh/uv/install.sh | sh     # if you do not have uv
uv venv --python 3.12 && source .venv/bin/activate
uv pip install rdkit pandas scikit-learn matplotlib jupyter ase
uv pip install langchain langchain-google-genai langchain-groq langgraph

jupyter lab
```

The first install line is all that Hands-on 1 needs, and it runs completely offline.

For the morning session, install **GNU Octave** (`octave.org/download`, or
`sudo apt install octave`) or use MATLAB.

### An API key, for Hands-on 2 only

The second notebook sends requests to a hosted language model. Create a free key at
`aistudio.google.com` (Get API key, then Create API key) and save it in a file called
`.env` in this folder:

```
GEMINI_API_KEY=your-key-here
```

A free key from `console.groq.com` works too; write `GROQ_API_KEY=` instead. Nothing is
charged and no card is needed.

Check it before you start:

```bash
python check-llm-key.py
```

That tests six things in order and tells you exactly which one fails.

**A note on model names.** They change every few months, and free quotas differ wildly
between them. The notebook tries a list and keeps the first that answers, so it keeps
working as names change. At the time of writing, avoid `gemini-3.8-flash` for teaching:
its free tier allows twenty requests per day, which one person exhausts in a single
exercise.

## What Hands-on 1 does

A molecule written as text becomes a row of numbers, and 1128 of them become a dataset
of measured aqueous solubility. The first model is fitted with `numpy.linalg.pinv`,
the same pseudoinverse taught in the morning, so the mathematics and the chemistry meet
within minutes of each other. Then a Morgan fingerprint is added, the fit explodes, and
working out why leads to the singular value decomposition and a one-line fix. A random
forest follows for comparison, and the session ends by predicting a molecule you type in
yourself.

## What Hands-on 2 does

An agent is a language model, a set of tools, and a loop. You give a model three tools
you already trust, two of them built in Hands-on 1, and ask it in plain English to do
chemistry. Every step of the loop is printed, so you can see the model choose a tool,
read the result, and answer from it rather than from memory.

## The data

| File | What it is |
|---|---|
| `data/esol.csv` | 1128 molecules with measured aqueous solubility. Delaney, *J. Chem. Inf. Comput. Sci.* 44 (2004) 1000. |
| `data/ch_oxidation.csv` | 575 molecules with several measured properties. From CHEM 5080 at Washington University in St. Louis. |
| `morning/data/digits.csv` | 1797 handwritten digits, 8x8 pixels, from the scikit-learn distribution of the UCI dataset. |
| `morning/data/esol_selfies.csv` | The solubility set again, with SELFIES strings, for the morning session. |

## Acknowledgement

The afternoon is shaped by **CHEM 5080, AI for Experimental Chemistry**, by Zhiling Zheng
at Washington University in St. Louis (`zzhenglab.github.io/ai4chem`), which is written
for chemists with no coding background and is generous enough to be shared freely. See
also Zheng, "Developing an AI Course for Synthetic Chemistry Students", *Journal of
Chemical Education* (2026). Our material is written independently; what we took from the
course is the shape of the syllabus, one dataset, and the idea of handing a trained model
to an agent as a tool.

## Running this workshop yourself

Two scripts help:

- `setup-lab.sh` builds the environment on a lab machine, or on a laptop whose own setup
  failed.
- `serve-to-room.sh` serves the whole bundle over the local network, so a room full of
  laptops can download it in one go without internet. It prints a URL to read out.

## Licence

Code and teaching material: MIT, see `LICENSE`. The datasets carry their original terms,
recorded in `data/README.md`.
