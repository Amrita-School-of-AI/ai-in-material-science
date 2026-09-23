#!/usr/bin/env bash
# Hand the workshop files to a room full of laptops over the local network, with no
# internet and no USB queue.
#
#   ./serve-to-room.sh
#
# It prints a URL. Participants type that URL into a browser and download a zip.
# Works on any venue wifi where the laptops can see each other. Stop it with Ctrl+C.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
PORT="${1:-8000}"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

echo "Packing..."
mkdir -p "$STAGE/ai-in-material-science"
cp -r "$HERE/notebooks" "$HERE/data" "$STAGE/ai-in-material-science/"
cp "$HERE/README.md" "$HERE/.env.example" "$HERE/check-llm-key.py" "$STAGE/ai-in-material-science/" 2>/dev/null || true
[ -d "$HERE/morning" ] && cp -r "$HERE/morning" "$STAGE/ai-in-material-science/"
[ -f "$HERE/deck/build/afternoon.pdf" ] && mkdir -p "$STAGE/ai-in-material-science/slides" \
  && cp "$HERE/deck/build/afternoon.pdf" "$STAGE/ai-in-material-science/slides/"
[ -f "$HERE/handout/build/reading-list.pdf" ] && mkdir -p "$STAGE/ai-in-material-science/handout" \
  && cp "$HERE/handout/build/reading-list.pdf" "$STAGE/ai-in-material-science/handout/"

# Never serve a key, and never serve the presenter's own notes.
find "$STAGE" -name '.env' -delete
rm -rf "$STAGE/ai-in-material-science/prep-guide" 2>/dev/null || true

cd "$STAGE"
zip -qr ai-in-material-science.zip ai-in-material-science
SIZE=$(du -h ai-in-material-science.zip | cut -f1)

cat > index.html <<HTML
<!doctype html><meta charset="utf-8"><title>AI in Material Science</title>
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>body{font-family:system-ui,sans-serif;max-width:34rem;margin:3rem auto;padding:0 1rem;
line-height:1.6;color:#16181d}h1{color:#7a1420;font-size:1.6rem;margin-bottom:.2rem}
.s{color:#767d91;margin-top:0}a.b{display:inline-block;background:#7a1420;color:#fff;
padding:.8rem 1.4rem;border-radius:6px;text-decoration:none;font-weight:600;margin:1rem 0}
code{background:#f6f7f9;padding:.15rem .35rem;border-radius:3px}</style>
<h1>AI in Material Science</h1>
<p class="s">University of Calicut, 24 September 2026 &middot; Amrita School of Artificial Intelligence</p>
<a class="b" href="ai-in-material-science.zip">Download everything ($SIZE)</a>
<p>Unzip it, then open a terminal in the folder:</p>
<p><code>cd ~/ai-materials &amp;&amp; source .venv/bin/activate &amp;&amp; jupyter lab</code></p>
<p>Start with <code>notebooks/01-molecules-in-python.ipynb</code>.</p>
<p>If your setup is not working, run <code>python check-llm-key.py</code> and show us what it prints.</p>
HTML

IP=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')
[ -z "$IP" ] && IP=$(hostname -I | awk '{print $1}')

echo
echo "  Tell the room to open:   http://$IP:$PORT"
echo "  Bundle size: $SIZE"
echo "  Ctrl+C to stop."
echo
python3 -m http.server "$PORT" --bind 0.0.0.0
