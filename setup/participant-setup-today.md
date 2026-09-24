---
title: Setting Up, Today
subtitle: "What to install and how to get the files, for the afternoon hands-on session"
kicker: AI in Material Science
footer: "AI in Material Science  ·  University of Calicut, 24 September 2026"
meta:
  - { k: Session, v: "Afternoon, 14:30 to 17:00" }
  - { k: You need, v: "A laptop and about fifteen minutes" }
  - { k: Files, v: "github.com/Amrita-School-of-AI/ai-in-material-science" }
  - { k: Help, v: "a_abhijith@cb.amrita.edu" }
---

## Read this first

The afternoon is hands-on. You will write Python that turns molecules into numbers,
predicts a property, and then hands those same tools to an AI agent.

If your laptop is not ready yet, that is fine. Follow step 1 and step 2 and you will be
ready in about fifteen minutes. **Ask for help the moment something does not work.**
Do not sit quietly with a broken screen, because the room moves together.

If you have no laptop, pair with somebody. Two people to a machine works well. Three does
not.

---

## Step 1. Get the files

Three ways. Try them in this order, and use whichever works.

| | How |
|---|---|
| **Internet works** | `git clone https://github.com/Amrita-School-of-AI/ai-in-material-science.git` <br> Or open that address in a browser and use the green **Code** button, then **Download ZIP**. |
| **Wifi works but the internet is slow** | We will put a web address on the screen, something like `http://192.168.x.x:8000`. Open it in a browser and download the zip. |
| **Nothing works** | Put up your hand. A USB stick is going round. |

Unzip it wherever you like. The folder is called `ai-in-material-science`.

---

## Step 2. Build the Python environment

You need **Linux or macOS**. On Windows, open PowerShell as Administrator, run
`wsl --install`, restart, and then use the Ubuntu window for everything below.

Open a terminal **inside the folder you just downloaded**, and run these lines one at a
time:

```
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Close the terminal, open it again in the same folder, then:

```
uv venv --python 3.12
source .venv/bin/activate
uv pip install rdkit pandas scikit-learn matplotlib jupyter ase
```

That is everything the first exercise needs, and it runs with no internet once installed.

For the second exercise, also run:

```
uv pip install langchain langchain-google-genai langchain-groq langgraph
```

!!! note
    **If the download is too slow or fails**, ask for the USB stick. It carries every
    package. Copy the `offline-install` folder out of it, then run
    `cd offline-install && ./install-offline.sh`. That installs everything with no
    internet at all.

---

## Step 3. A free API key, for the second exercise only

The agent in the second notebook talks to a language model running on Google's servers.
You need your own free key. It costs nothing and does not ask for a card.

1. Go to **`aistudio.google.com`** and sign in with any Google account.
2. Click **Get API key**, then **Create API key**.
3. Copy the key.
4. In the workshop folder, make a file called `.env` containing one line:

```
GEMINI_API_KEY=paste-your-key-here
```

Treat it like a password. Do not post it in a group chat.

!!! pitfall
    Make your own key. If forty people share one key, the daily limit is reached within
    minutes and nobody can finish. If you cannot make one, pair with someone who has.

---

## Step 4. Check that it works

With the environment active, in the workshop folder:

```
python check-llm-key.py
```

It tests six things and tells you which one failed. When the last line says
**`PASS. Hands-on 2 will work.`** you are ready for the whole afternoon.

If you are only doing the first exercise, this check is enough:

```
python -c "from rdkit import Chem; print(Chem.MolToSmiles(Chem.MolFromSmiles('CCO')), 'ready')"
```

---

## Step 5. Open the notebooks

```
jupyter lab
```

Your browser opens. Go into `notebooks/` and open
**`01-molecules-in-python.ipynb`**. Run cells from the top with **Shift+Enter**.

We will work through it together, so do not run ahead.

The second notebook, `02-agent-that-does-chemistry.ipynb`, comes after tea.

---

## When something breaks

| It says | Do this |
|---|---|
| `command not found: uv` | Close the terminal and open it again, so it picks up the new command. |
| `No module named rdkit` | The environment is not active. Run `source .venv/bin/activate` first. Your prompt should change. |
| `429` or `RESOURCE_EXHAUSTED` | You have hit the free daily limit on that model. Tell us and we will switch you to another one. |
| `400 INVALID_ARGUMENT` | Usually a mistyped key. Check the `.env` file has no spaces around the `=`. |
| Anything else | Raise your hand. Do not lose twenty minutes to it quietly. |

---

## Afterwards

Everything stays at
**`github.com/Amrita-School-of-AI/ai-in-material-science`**, including the slides, the
reading list and the morning session's MATLAB and Octave code. Clone it any time.

The obvious next step is to replace `data/esol.csv` with measurements from your own
laboratory. Any table with a column of SMILES and a column of numbers will work, and only
the column names in section 3 of the first notebook need to change.

Questions after today: `a_abhijith@cb.amrita.edu`
