#!/usr/bin/env python3
"""Check that an API key works, end to end, before the workshop.

    python check-llm-key.py

Reads the key from .env, finds a model that answers, makes one plain call, then runs a
real tool call through the agent. Prints exactly what fails if anything does.
"""

import os
import sys
import warnings
from pathlib import Path

warnings.filterwarnings("ignore", message=".*fixed sampling defaults.*")

for candidate in [Path(".env"), Path("../.env"), Path.home() / "ai-materials/.env"]:
    if candidate.exists():
        for line in candidate.read_text().splitlines():
            if "=" in line and not line.strip().startswith("#"):
                k, v = line.split("=", 1)
                os.environ.setdefault(k.strip(), v.strip())
        print(f"1. key file    : found {candidate}")
        break
else:
    sys.exit("1. key file    : FAILED. No .env found. Create one holding "
             "GEMINI_API_KEY=your-key")

gem = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
groq = os.environ.get("GROQ_API_KEY")
if not (gem or groq):
    sys.exit("2. key present : FAILED. The .env file has no GEMINI_API_KEY or GROQ_API_KEY.")
key = gem or groq
print(f"2. key present : yes, {len(key)} characters, starts {key[:6]}...")

from langchain.chat_models import init_chat_model

if gem:
    os.environ.setdefault("GOOGLE_API_KEY", gem)
    provider, candidates = "google_genai", ["gemini-3.5-flash-lite", "gemini-3.1-flash-lite", "gemini-3.6-flash", "gemini-3.7-flash"]
else:
    provider, candidates = "groq", ["openai/gpt-oss-120b", "openai/gpt-oss-20b", "llama-3.3-70b-versatile"]

llm = None
for name in candidates:
    try:
        trial = init_chat_model(name, model_provider=provider, temperature=0)
        trial.invoke("Reply with the single word: ready")
        llm = trial
        print(f"3. model       : {name} answers")
        break
    except Exception as e:
        print(f"   {name} unavailable: {str(e)[:100]}")

if llm is None:
    sys.exit("3. model       : FAILED. No model answered. The key may be new and still "
             "propagating, or the project may need the Generative Language API enabled.")

def text_of(message):
    """Pull plain text out of a reply, whether it is a string or a list of blocks."""
    c = message.content
    if isinstance(c, str):
        return c
    return " ".join(b.get("text", "") for b in c if isinstance(b, dict)).strip()

print("4. plain call  :", text_of(llm.invoke("In one sentence, what is SMILES notation?"))[:90])

# The real test: can it call a tool and use the result.
import json
from langchain_core.tools import tool
from rdkit import Chem, RDLogger
from rdkit.Chem import Descriptors
RDLogger.DisableLog("rdApp.*")

@tool
def molecule_properties(smiles: str) -> str:
    """Compute exact molecular properties for a molecule given as a SMILES string."""
    mol = Chem.MolFromSmiles(smiles)
    return json.dumps({"MolWt": round(Descriptors.MolWt(mol), 3)})

try:
    from langchain.agents import create_agent
except ImportError:
    from langgraph.prebuilt import create_react_agent as create_agent

agent = create_agent(llm, [molecule_properties])
result = agent.invoke({"messages": [("user", "What is the exact molecular weight of "
                                     "paracetamol? Its SMILES is CC(=O)Nc1ccc(O)cc1. "
                                     "Use the tool.")]})
called = any(getattr(m, "tool_calls", None) for m in result["messages"])
print(f"5. tool call   : {'the model called the tool' if called else 'NO TOOL CALL, it answered from memory'}")
print("6. answer      :", text_of(result["messages"][-1])[:110])

print("\nPASS. Hands-on 2 will work." if called else
      "\nPARTIAL. The model answered without calling the tool. Try the next model in the list.")
