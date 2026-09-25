# Running this workshop again, somewhere else

The workshop ran at the University of Calicut on 24 September 2026. Everything needed to
run it again is in this folder. Nothing lives in the home directory and nothing important
lives in a temporary directory.

Budget about an hour, most of it downloading.

---

## 1. Change the venue details

Edit **`course.yaml`**. It is the only file that names a place or a date, and every PDF
is stamped from it:

```yaml
offering:
  term: "University of Calicut, 24 September 2026"   <- change this
schedule:
  date: "2026-09-24"                                  <- and this
resource_persons:                                     <- and these, if they differ
```

Then rebuild every document:

```bash
bash tools/build-all-documents.sh
```

## 2. Build the environments

```bash
bash tools/build-run-env.sh          # run/, the presenter's working copy
bash tools/build-chemgraph-env.sh    # env/chemgraph, for the closing demonstration
```

The first installs from `offline-install/` when the wheels are there, so it works with no
internet. The second needs about 1.8 GB from the network.

## 3. Put the keys in place

Create `material/.env` holding whichever keys you have:

```
GEMINI_API_KEY=...
GROQ_API_KEY=...
OPENAI_API_KEY=...
```

Then check it:

```bash
cd run && .venv/bin/python check-llm-key.py
```

Six checks. The last line should read `PASS. Hands-on 2 will work.`

## 4. Make the USB stick

```bash
./make-usb-bundle.sh /media/<you>/<STICK>
```

Copies the material, the slides, both participant PDFs and the 148-wheel offline
installer. It refuses to finish if host contact details or presenter-only material have
crept in.

## 5. On the day

`START-OF-DAY.md` has the order of operations. In short: hand out the files by repository,
by `run/serve-to-room.sh` over the local network, or by USB, in that order of preference.

---

## What is where

| Path | What it holds | Keep? |
|---|---|---|
| `material/` | **The source of truth.** Notebook sources, deck source, document sources, data, the morning cells. | Yes |
| `admin/programme-guide/` | The hosts' programme chart and participant guide. | Yes |
| `docs/` | The brief, the source readings, the CHEM 5080 map, correspondence drafts. | Yes |
| `offline-install/` | 148 wheels, 205 MB. Makes the USB work without internet. | Yes, unless disk is short |
| `repo/` | Working clone of the public GitHub repository. | Yes |
| `tools/` | Build scripts: documents, environments, notebook conversion. | Yes |
| `reading/` | Copies of the sources, including the CHEM 5080 lectures. | Yes |
| `run/` | The presenter's working copy, environment included. **Regenerable**: `tools/build-run-env.sh`. | Delete to save 900 MB |
| `env/chemgraph/` | ChemGraph, 1.8 GB. **Regenerable**: `tools/build-chemgraph-env.sh`. | Delete to save 1.8 GB |

Deleting `run/` and `env/` takes the project from about 3 GB to about 230 MB, and both
rebuild from the scripts above. Do that before archiving to the drive.

---

## Things that cost time to rediscover

- **`gemini-3.8-flash` allows twenty free requests per day.** Use the Flash-Lite models.
  Nothing in the notebooks names a model; `material/workshop_llm.py` holds the list and
  tries Gemini, then Groq, then OpenAI.
- **A free Groq key cannot reach the Llama models.** They return 404 as Enterprise tier.
  Use `openai/gpt-oss-120b`.
- **ChemGraph does not work with Gemini.** Google rejects its tool schema with a 400 on
  every model. Use Groq or OpenAI, and note that ChemGraph accepts only models on its own
  list, so the OpenAI fallback is `gpt-4o-mini`.
- **Install torch from the CPU index** on a machine without an NVIDIA card, or pip pulls
  four gigabytes of unusable CUDA.
- **`pip install chemgraph` without a version** resolves to an unrelated package when it
  sits beside pinned scientific libraries. Pin `chemgraph==0.7.0`.
- **The notebooks' `.py` files are the source**, not the `.ipynb`. Edit the script, run it
  to test, then regenerate with `python3 tools/py2nb.py <in.py> <out.ipynb>`.
- **Render any PDF you change and look at it.** Both build gates passed on a deck whose
  section dividers were white text on white paper.
