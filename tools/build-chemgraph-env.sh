#!/usr/bin/env bash
# Rebuild the ChemGraph environment for the presenter demonstration, CPU-only.
#
#   bash tools/build-chemgraph-env.sh
#
# Creates env/chemgraph, about 1.8 GB. Installing torch from PyPI instead of the CPU
# index pulls roughly four gigabytes of CUDA libraries that a laptop without an NVIDIA
# card cannot use, so the order below matters.

set -euo pipefail
cd "$(dirname "$0")/.."

export UV_HTTP_TIMEOUT=600
rm -rf env/chemgraph
uv venv --python 3.12 env/chemgraph

# CPU-only torch first, so the resolver never reaches for the CUDA build.
uv pip install --python env/chemgraph/bin/python \
    --index-url https://download.pytorch.org/whl/cpu torch

# Pin the version. A bare `chemgraph` resolves to an unrelated 0.0.x package when it
# sits beside pinned scientific libraries.
uv pip install --python env/chemgraph/bin/python "chemgraph==0.7.0"

env/chemgraph/bin/python - <<'PY'
import chemgraph, importlib.metadata as md
from ase.build import molecule
from ase.calculators.emt import EMT
from ase.optimize import BFGS
m = molecule("H2O"); m.calc = EMT(); BFGS(m, logfile=None).run(fmax=0.05)
print("chemgraph", md.version("chemgraph"), "| H2O", round(m.get_potential_energy(), 4), "eV")
PY

echo
echo "Done. Demonstrate with:  cd run && ./run-chemgraph-demo.sh"
echo "ChemGraph needs a Groq or OpenAI key. Gemini does not work: Google rejects its tool schema."
