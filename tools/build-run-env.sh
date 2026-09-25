#!/usr/bin/env bash
# Rebuild the presenter's working environment at run/.
#
#   bash tools/build-run-env.sh
#
# Installs from the bundled wheels when they are present, so it works with no internet.

set -euo pipefail
cd "$(dirname "$0")/.."

export UV_HTTP_TIMEOUT=600
uv venv --python 3.12 run/.venv

PKGS="rdkit pandas scikit-learn matplotlib jupyter ase selfies
      langchain langchain-google-genai langchain-groq langchain-openai langgraph"

if [ -d offline-install ] && ls offline-install/*.whl >/dev/null 2>&1; then
  echo "Installing from the bundled wheels, no network needed."
  uv pip install --python run/.venv/bin/python --offline --no-index \
      --find-links=offline-install $PKGS || {
    echo "Some packages are not in the bundle. Falling back to PyPI."
    uv pip install --python run/.venv/bin/python $PKGS
  }
else
  uv pip install --python run/.venv/bin/python $PKGS
fi

# Put the material beside the environment.
mkdir -p run/notebooks run/data run/slides run/handout
cp material/notebooks/*.ipynb material/notebooks/*.py run/notebooks/
cp material/data/*.csv material/data/README.md run/data/
cp material/workshop_llm.py material/check-llm-key.py material/README.md run/
cp material/setup-lab.sh material/serve-to-room.sh material/run-chemgraph-demo.sh run/
cp -r material/morning run/
[ -f material/deck/build/afternoon.pdf ] && cp material/deck/build/afternoon.pdf run/slides/
[ -f material/handout/build/reading-list.pdf ] && cp material/handout/build/reading-list.pdf run/handout/
[ -f material/.env ] && cp -n material/.env run/.env && chmod 600 run/.env

run/.venv/bin/python -c "from rdkit import Chem; print('ready:', Chem.MolToSmiles(Chem.MolFromSmiles('CCO')))"
echo
echo "Done. Check the language model with:  cd run && .venv/bin/python check-llm-key.py"
