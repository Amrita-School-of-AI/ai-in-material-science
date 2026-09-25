#!/usr/bin/env bash
# The closing demonstration: ChemGraph, a research agent from Argonne National
# Laboratory, doing real computational chemistry from one sentence.
#
#   ./run-chemgraph-demo.sh                        the default water question
#   ./run-chemgraph-demo.sh "your question here"   anything else
#
# Tries Groq first, then OpenAI. Gemini is deliberately not attempted: Google rejects
# ChemGraph's tool schema, so it fails every time with a 400.

set -uo pipefail
cd "$(dirname "$0")"

key() { grep -m1 "^$1=" .env 2>/dev/null | cut -d= -f2- ; }
export GROQ_API_KEY="$(key GROQ_API_KEY)"
export OPENAI_API_KEY="$(key OPENAI_API_KEY)"

Q="${1:-Build water from SMILES O, optimize with EMT, and report the final energy.}"
# ChemGraph lives inside the project. Look beside us, then one level up, so this works
# from run/ and from material/ alike.
CG=""
for c in "./env/chemgraph/bin/chemgraph" "../env/chemgraph/bin/chemgraph" \
         "../../env/chemgraph/bin/chemgraph"; do
  [ -x "$c" ] && { CG="$(cd "$(dirname "$c")" && pwd)/chemgraph"; break; }
done
[ -n "$CG" ] || { echo "ChemGraph not found. Rebuild it with: bash tools/build-chemgraph-env.sh"; exit 1; }

OUT="$(mktemp)"
trap 'rm -f "$OUT"' EXIT

echo "Question: $Q"
echo

for MODEL in "groq:openai/gpt-oss-120b" "groq:openai/gpt-oss-20b" "gpt-4o-mini"; do
  case "$MODEL" in
    groq:*) [ -n "$GROQ_API_KEY" ] || continue ;;
    *)      [ -n "$OPENAI_API_KEY" ] || continue
            echo "Groq did not work. Falling back to OpenAI, which is a paid key." ;;
  esac

  echo "--- $MODEL"
  "$CG" run -q "$Q" -m "$MODEL" -o last_message > "$OUT" 2>&1
  status=$?

  if [ $status -eq 0 ] && ! grep -qiE 'error processing query|not found in any supported' "$OUT"; then
    grep -viE 'fairchem|tblite|^WARNING' "$OUT"
    echo
    echo "--- ran on $MODEL"
    exit 0
  fi

  echo "    that one did not work:"
  grep -iE 'error processing query|not found in any supported' "$OUT" | head -2 | sed 's/^/      /'
done

echo
echo "ChemGraph could not run. This is a demonstration only, so carry on:"
echo "the agent the participants built in notebook 2 makes the same point."
exit 1
