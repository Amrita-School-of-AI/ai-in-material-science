#!/usr/bin/env python3
"""Convert a percent-format .py into a .ipynb with no outputs."""
import sys, re, json

def convert(src, dst):
    text = open(src, encoding="utf-8").read()
    parts = re.split(r"^# %%(.*)$", text, flags=re.M)
    cells, i = [], 1
    while i < len(parts):
        header, body = parts[i].strip(), parts[i + 1]
        lines = body.split("\n")
        while lines and not lines[0].strip():
            lines.pop(0)
        while lines and not lines[-1].strip():
            lines.pop()
        if not lines:
            i += 2; continue
        if header.startswith("[markdown]"):
            src_lines = [re.sub(r"^# ?", "", l) for l in lines]
            cells.append({"cell_type": "markdown", "metadata": {},
                          "source": [l + "\n" for l in src_lines[:-1]] + [src_lines[-1]]})
        else:
            cells.append({"cell_type": "code", "metadata": {}, "execution_count": None,
                          "outputs": [],
                          "source": [l + "\n" for l in lines[:-1]] + [lines[-1]]})
        i += 2
    nb = {"cells": cells,
          "metadata": {"kernelspec": {"display_name": "Python 3", "language": "python",
                                      "name": "python3"},
                       "language_info": {"name": "python", "version": "3.12"}},
          "nbformat": 4, "nbformat_minor": 5}
    json.dump(nb, open(dst, "w", encoding="utf-8"), indent=1)
    print(f"{dst}: {len(cells)} cells")

if __name__ == "__main__":
    convert(sys.argv[1], sys.argv[2])
