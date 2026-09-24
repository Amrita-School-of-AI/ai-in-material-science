#!/usr/bin/env python3
"""Check that the workshop's language-model setup works, before the session.

    python check-llm-key.py            test the automatic choice
    python check-llm-key.py groq       force one provider

Six checks in order. The first that fails tells you what to fix.
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

prefer = sys.argv[1] if len(sys.argv) > 1 else None

from workshop_llm import get_llm, text_of, load_keys, PROVIDERS

found = load_keys()
if not found:
    sys.exit("1. key file    : FAILED. No .env found holding a key. Create one containing\n"
             "                 GEMINI_API_KEY=your-key-here")
print(f"1. key file    : found keys {', '.join(found)}")

import os
available = [p for p, envs, _, _ in PROVIDERS if any(os.environ.get(e) for e in envs)]
print(f"2. providers   : {len(available)} configured ({', '.join(available)})")
if len(available) > 1:
    print(f"                 if one fails on the day, the notebook moves to the next")

try:
    llm = get_llm(prefer=prefer)
except Exception as exc:
    sys.exit(f"3. model       : FAILED.\n{exc}")
print("3. model       : answered")

print("4. plain call  :", text_of(llm.invoke("In one sentence, what is SMILES notation?"))[:80])

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

result = create_agent(llm, [molecule_properties]).invoke(
    {"messages": [("user", "What is the exact molecular weight of paracetamol? Its SMILES "
                           "is CC(=O)Nc1ccc(O)cc1. Use the tool.")]})
called = any(getattr(m, "tool_calls", None) for m in result["messages"])
print(f"5. tool call   : {'the model called the tool' if called else 'NO TOOL CALL, it answered from memory'}")
print("6. answer      :", text_of(result["messages"][-1])[:100])

print("\nPASS. Hands-on 2 will work." if called else
      "\nPARTIAL. The model answered without calling the tool. Try another provider:\n"
      "  python check-llm-key.py groq")
