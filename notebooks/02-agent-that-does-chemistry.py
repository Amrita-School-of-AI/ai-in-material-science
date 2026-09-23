# %% [markdown]
# # Hands-on 2: an agent that does chemistry
#
# AI in Material Science, University of Calicut, 24 September 2026
#
# An agent is three things: a language model, a set of tools it is allowed to call, and
# a loop that runs until the job is done. Nothing more.
#
# In this notebook you will give a model three tools you already trust, two of them from
# Hands-on 1, and then ask it in plain English to do chemistry with them.
#
# You need the free API key you created before the workshop. Nothing here costs money.

# %%
import os, json
from pathlib import Path
import warnings

# Flash-Lite ignores the temperature setting and says so on every call. True, and not
# worth four lines on screen.
warnings.filterwarnings("ignore", message=".*fixed sampling defaults.*")

# Read the key from the .env file you made during setup. We look in the usual places
# so it does not matter exactly where you put it.
for candidate in [Path(".env"), Path("../.env"), Path("../../.env"), Path.home() / "ai-materials/.env"]:
    if candidate.exists():
        for line in candidate.read_text().splitlines():
            if "=" in line and not line.strip().startswith("#"):
                k, v = line.split("=", 1)
                os.environ.setdefault(k.strip(), v.strip())
        print("read key file:", candidate)
        break

have_gemini = bool(os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY"))
have_groq = bool(os.environ.get("GROQ_API_KEY"))
print("Gemini key found:", have_gemini, " Groq key found:", have_groq)
if not (have_gemini or have_groq):
    print("\nNo key yet. Paste it in the next cell and run it.")

# %%
# If the check above said no key, uncomment the line for your provider and paste it in.
# os.environ["GEMINI_API_KEY"] = "paste-your-key-here"
# os.environ["GROQ_API_KEY"] = "paste-your-key-here"

# %% [markdown]
# ## 1. One call to a language model
#
# Before any agent, see the plain call. The model gets text and returns text.

# %%
from langchain.chat_models import init_chat_model

# Model names change every few months, so try a short list and keep the first that
# answers. If they all fail, the provider's console lists what your key can reach.
if os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY"):
    os.environ.setdefault("GOOGLE_API_KEY", os.environ.get("GEMINI_API_KEY", ""))
    provider = "google_genai"
    candidates = ["gemini-3.5-flash-lite", "gemini-3.1-flash-lite", "gemini-3.6-flash", "gemini-3.7-flash"]
else:
    provider = "groq"
    candidates = ["llama-3.3-70b-versatile", "openai/gpt-oss-120b", "llama-3.1-8b-instant"]

def text_of(message):
    """Pull plain text out of a reply. Newer Gemini models return a list of blocks
    rather than a plain string, and printing that raw fills the screen."""
    c = message.content
    if isinstance(c, str):
        return c
    return " ".join(b.get("text", "") for b in c if isinstance(b, dict)).strip()

llm = None
for name in candidates:
    try:
        trial = init_chat_model(name, model_provider=provider, temperature=0)
        trial.invoke("Reply with the single word: ready")
        llm = trial
        print("using", provider, name)
        break
    except Exception as e:
        print("could not use", name, "|", str(e)[:90])

if llm is None:
    raise SystemExit("No model answered. Check the key in .env, and check the provider "
                     "console for the model names your key can reach.")

# %%
print(text_of(llm.invoke("In one sentence, what does a chemist use SMILES notation for?")))

# %% [markdown]
# Now ask it something it cannot know reliably.

# %%
print(text_of(llm.invoke("What is the exact molecular weight of paracetamol, to three decimal places? Answer with the number only.")))

# %% [markdown]
# Run that cell two or three times. The answer may wobble, and it may be wrong in the
# third decimal. The model is recalling text, not computing anything.
#
# RDKit computes it exactly. The fix is to let the model call RDKit.

# %%
from rdkit import Chem
from rdkit.Chem import Descriptors
print("RDKit says:", round(Descriptors.MolWt(Chem.MolFromSmiles("CC(=O)Nc1ccc(O)cc1")), 3))

# %% [markdown]
# ## 2. Three tools
#
# A tool is an ordinary Python function with a description. The description is what the
# model reads when it decides which tool to call, so it matters as much as the code.

# %%
import numpy as np
from langchain_core.tools import tool
from rdkit.Chem import Crippen, rdMolDescriptors

@tool
def molecule_properties(smiles: str) -> str:
    """Compute exact molecular properties for a molecule given as a SMILES string.
    Returns molecular weight, logP, topological polar surface area and ring count."""
    mol = Chem.MolFromSmiles(smiles)
    if mol is None:
        return f"'{smiles}' is not a valid SMILES string."
    return json.dumps({
        "smiles": Chem.MolToSmiles(mol),
        "MolWt": round(Descriptors.MolWt(mol), 3),
        "LogP": round(Crippen.MolLogP(mol), 3),
        "TPSA": round(rdMolDescriptors.CalcTPSA(mol), 2),
        "NumRings": rdMolDescriptors.CalcNumRings(mol),
        "NumAtoms": mol.GetNumAtoms(),
    })

@tool
def optimise_geometry(smiles: str) -> str:
    """Build a 3D structure for a SMILES string, relax it with the EMT calculator,
    and return the final potential energy in eV and the number of optimisation steps.
    Works offline. Reliable only for small molecules made of common elements."""
    from ase import Atoms
    from ase.calculators.emt import EMT
    from ase.optimize import BFGS
    from rdkit.Chem import AllChem

    mol = Chem.MolFromSmiles(smiles)
    if mol is None:
        return f"'{smiles}' is not a valid SMILES string."
    mol = Chem.AddHs(mol)
    if AllChem.EmbedMolecule(mol, randomSeed=0) != 0:
        return "Could not generate a 3D structure for this molecule."
    AllChem.MMFFOptimizeMolecule(mol)
    conf = mol.GetConformer()
    symbols = [a.GetSymbol() for a in mol.GetAtoms()]
    positions = [list(conf.GetAtomPosition(i)) for i in range(mol.GetNumAtoms())]

    atoms = Atoms(symbols=symbols, positions=positions)
    atoms.calc = EMT()
    before = atoms.get_potential_energy()
    opt = BFGS(atoms, logfile=None)
    opt.run(fmax=0.05, steps=200)
    return json.dumps({
        "formula": atoms.get_chemical_formula(),
        "energy_before_eV": round(float(before), 4),
        "energy_after_eV": round(float(atoms.get_potential_energy()), 4),
        "steps": int(opt.get_number_of_steps()),
    })

# The model fitted in Hands-on 1. If that file is not here, fit it again from the same
# data in three lines, so this notebook works on its own.
if Path("solubility_model.npz").exists():
    _w = np.load("solubility_model.npz", allow_pickle=True)["w_train"]
else:
    import pandas as pd
    _d = pd.read_csv("../data/esol.csv")
    _rows, _y = [], []
    for _smi, _logS in zip(_d["smiles"], _d["logS"]):
        _m = Chem.MolFromSmiles(_smi)
        if _m is None:
            continue
        _rows.append([1.0, Descriptors.MolWt(_m), Crippen.MolLogP(_m),
                      rdMolDescriptors.CalcTPSA(_m), rdMolDescriptors.CalcNumRings(_m)])
        _y.append(_logS)
    _w = np.linalg.pinv(np.array(_rows)) @ np.array(_y)
    print("refitted the solubility model from ../data/esol.csv")

@tool
def predict_solubility(smiles: str) -> str:
    """Predict the aqueous solubility (logS, log mol/L) of a molecule from its SMILES,
    using the linear model fitted on 1128 measured molecules in the previous session.
    A larger value means the molecule dissolves better in water."""
    mol = Chem.MolFromSmiles(smiles)
    if mol is None:
        return f"'{smiles}' is not a valid SMILES string."
    row = np.array([1.0,
                    Descriptors.MolWt(mol),
                    Crippen.MolLogP(mol),
                    rdMolDescriptors.CalcTPSA(mol),
                    rdMolDescriptors.CalcNumRings(mol)])
    return json.dumps({"smiles": Chem.MolToSmiles(mol), "predicted_logS": round(float(row @ _w), 2)})

tools = [molecule_properties, optimise_geometry, predict_solubility]
for t in tools:
    print(t.name, "->", t.description.split("\n")[0])

# %%
# The tools are ordinary functions. Check them before handing them to a model.
print(molecule_properties.invoke({"smiles": "CC(=O)Nc1ccc(O)cc1"}))
print(predict_solubility.invoke({"smiles": "CCO"}))

# %% [markdown]
# ## 3. The loop
#
# `create_agent` wires the model to the tools and runs the loop: the model either
# answers, or asks for a tool; if it asks, the tool runs and the result goes back to the
# model; repeat until it answers.

# %%
# The helper moved between versions of LangChain. Either import works.
try:
    from langchain.agents import create_agent
except ImportError:
    from langgraph.prebuilt import create_react_agent as create_agent

agent = create_agent(llm, tools)

def ask(question):
    """Send a question to the agent and print every step of the loop."""
    result = agent.invoke({"messages": [("user", question)]})
    for m in result["messages"]:
        kind = m.__class__.__name__.replace("Message", "")
        if getattr(m, "tool_calls", None):
            for call in m.tool_calls:
                print(f"  [model asks for] {call['name']}({call['args']})")
        elif kind == "Tool":
            print(f"  [tool returns ] {m.content[:160]}")
        elif kind == "AI" and text_of(m):
            print(f"\n[answer] {text_of(m)}")
    return result

# %%
ask("What is the exact molecular weight of paracetamol? Its SMILES is CC(=O)Nc1ccc(O)cc1.")

# %% [markdown]
# Look at the trace. The model did not answer from memory. It asked for a tool, read the
# result, and answered from it. That is the whole idea.

# %% [markdown]
# ## 4. Two tools in one request

# %%
ask("Build water from the SMILES O, optimise its geometry with EMT, and report the final energy.")

# %%
ask("Between ethanol (CCO) and naphthalene (c1ccc2ccccc2c1), which dissolves better in "
    "water? Use the solubility tool for both and explain the difference in one sentence.")

# %% [markdown]
# ## 5. Your turn
#
# Three prompts to try. Write your own in the empty cell after them.
#
# 1. Ask it to compare the polar surface area of aspirin and caffeine and say which is
#    more likely to cross a cell membrane.
# 2. Give it a molecule from your own work and ask for properties and solubility.
# 3. Ask it something none of the tools can answer, and watch what it does.

# %%
ask("Compare the topological polar surface area of aspirin (CC(=O)Oc1ccccc1C(=O)O) and "
    "caffeine (Cn1cnc2c1c(=O)n(C)c(=O)n2C). Which is more likely to cross a cell membrane?")

# %%
# Your own prompt:
# ask("...")

# %% [markdown]
# ## 6. Where this goes
#
# What you just built is the small version of what research groups now run:
#
# - **ChemGraph** (Argonne National Laboratory) wires the same loop to real quantum
#   chemistry codes and machine-learned potentials, so a sentence becomes a calculation.
# - **Scientific agent skills** give an agent ready-made competence in RDKit, pymatgen,
#   DeepChem and around a hundred databases.
# - A **self-driving laboratory** closes the loop through hardware: the agent chooses the
#   next experiment, a robot runs it, an instrument measures it, and the result changes
#   what it asks for next.
#
# The parts are the same in all three: a model, tools it can call, and a loop.

# %% [markdown]
# ## What to take away
#
# - A language model alone is a confident guesser. Given tools, it becomes useful.
# - A tool is a plain function plus a clear description of when to use it.
# - You keep control of what the tools do. The model only chooses when to call them.
# - The model in Hands-on 1 became a tool in Hands-on 2. That is how these systems grow.
