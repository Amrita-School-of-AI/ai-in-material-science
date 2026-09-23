#!/usr/bin/env bash
# Set up one Linux machine for the afternoon session of the AI in Material Science
# workshop. Safe to run more than once: it reuses the environment if it is already there.
#
#   ./setup-lab.sh            install into ~/ai-materials
#   ./setup-lab.sh /opt/ai    install somewhere else
#
# Run it on every machine in the fallback lab, or on a participant's laptop whose own
# setup failed.

set -euo pipefail

TARGET="${1:-$HOME/ai-materials}"
HERE="$(cd "$(dirname "$0")" && pwd)"

echo "Installing the workshop environment into $TARGET"

mkdir -p "$TARGET"
cp -r "$HERE/notebooks" "$HERE/data" "$TARGET/" 2>/dev/null || true
[ -f "$HERE/.env.example" ] && cp -n "$HERE/.env.example" "$TARGET/.env" 2>/dev/null || true

if ! command -v uv >/dev/null 2>&1; then
  echo "Installing uv"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

cd "$TARGET"
if [ ! -d .venv ]; then
  uv venv --python 3.12
fi
# shellcheck disable=SC1091
source .venv/bin/activate

# Hands-on 1 first, so a machine with a slow link is usable for the first exercise even
# if the second install is still running.
uv pip install rdkit pandas scikit-learn matplotlib jupyter ase
uv pip install langchain langchain-google-genai langchain-groq langgraph

python - <<'PY'
from rdkit import Chem
import sklearn, pandas, ase, numpy
print("rdkit, sklearn, pandas, ase all import")
print("check molecule:", Chem.MolToSmiles(Chem.MolFromSmiles("CCO")))
PY

cat <<MSG

Done. To use it:

    cd $TARGET
    source .venv/bin/activate
    jupyter lab

Then open notebooks/01-molecules-in-python.ipynb.

For Hands-on 2, put your API key in $TARGET/.env as

    GEMINI_API_KEY=your-key-here

MSG
