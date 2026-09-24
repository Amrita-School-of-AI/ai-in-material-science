"""Find a language model that works, whatever the room throws at us.

    from workshop_llm import get_llm, text_of
    llm = get_llm()

Tries the providers in order of preference and keeps the first model that actually
answers. Preference is deliberate:

  1. Google Gemini   free, and what the participants were told to create
  2. Groq            free, different company, so it survives a Google outage
  3. OpenAI          paid, so it is the presenter's fallback and never the default

Every model name here was verified on 24 September 2026. They change often, which is
exactly why this file exists: nothing downstream names a model.
"""

from __future__ import annotations

import os
import warnings
from pathlib import Path

warnings.filterwarnings("ignore", message=".*fixed sampling defaults.*")

# Provider, the environment variable that switches it on, and models worth trying.
PROVIDERS = [
    ("google_genai", ("GEMINI_API_KEY", "GOOGLE_API_KEY"), False,
     ["gemini-3.5-flash-lite", "gemini-3.1-flash-lite", "gemini-3.6-flash", "gemini-3.7-flash"]),
    ("groq", ("GROQ_API_KEY",), False,
     ["openai/gpt-oss-120b", "openai/gpt-oss-20b"]),
    ("openai", ("OPENAI_API_KEY",), True,
     ["gpt-4.1-mini", "gpt-4o-mini", "gpt-5-mini"]),
]

KEY_FILES = [Path(".env"), Path("../.env"), Path("../../.env"), Path.home() / "ai-materials/.env"]


def load_keys(verbose: bool = False) -> list[str]:
    """Read the first .env we can find. Returns the names of the keys it set."""
    for path in KEY_FILES:
        if not path.exists():
            continue
        found = []
        for line in path.read_text().splitlines():
            line = line.strip()
            if "=" in line and not line.startswith("#"):
                k, v = line.split("=", 1)
                k, v = k.strip(), v.strip()
                if v and not v.startswith("paste-"):
                    os.environ.setdefault(k, v)
                    found.append(k)
        if found:
            if verbose:
                print(f"keys from {path}: {', '.join(found)}")
            # Gemini is read from either name depending on the library version.
            if "GEMINI_API_KEY" in os.environ:
                os.environ.setdefault("GOOGLE_API_KEY", os.environ["GEMINI_API_KEY"])
            return found
    return []


def text_of(message) -> str:
    """Plain text from a reply. Newer Gemini models return a list of blocks."""
    content = message.content
    if isinstance(content, str):
        return content
    return " ".join(b.get("text", "") for b in content if isinstance(b, dict)).strip()


def get_llm(prefer: str | None = None, quiet: bool = False):
    """Return the first working chat model, or raise with a readable explanation.

    prefer: force one provider, for example get_llm("groq").
    """
    from langchain.chat_models import init_chat_model

    load_keys()
    tried = []

    for provider, env_names, is_paid, models in PROVIDERS:
        if prefer and provider != prefer:
            continue
        if not any(os.environ.get(n) for n in env_names):
            tried.append(f"{provider}: no key")
            continue
        for name in models:
            try:
                llm = init_chat_model(name, model_provider=provider)
                llm.invoke("Reply with one word: ready")
                if not quiet:
                    note = "  (paid, this one costs money)" if is_paid else ""
                    print(f"using {provider} {name}{note}")
                return llm
            except Exception as exc:
                tried.append(f"{provider} {name}: {str(exc)[:70]}")

    raise RuntimeError(
        "No language model answered.\n  " + "\n  ".join(tried) +
        "\n\nCheck that .env holds a key, and that the machine is online."
    )
