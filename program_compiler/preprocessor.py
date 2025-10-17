#!/usr/bin/env python3
"""
preprocessor.py — remove comments from an assembly file.

Usage:
    python preprocessor.py input.s output.s

Removes anything from the first occurrence of: //  #  ;
Keeps blank lines and labels intact (just trims trailing whitespace).
"""
import sys
from pathlib import Path

if len(sys.argv) != 3:
    print("Usage: python preprocessor.py input.s output.s")
    sys.exit(1)

inp = Path(sys.argv[1]).read_text().splitlines()
out_lines = []
for line in inp:
    # find earliest comment delimiter occurrence
    idxs = [line.find(d) for d in ("//", "#", ";")]
    # keep only non-negative indexes
    idxs = [i for i in idxs if i != -1]
    if idxs:
        cut = min(idxs)
        new = line[:cut].rstrip()
    else:
        new = line.rstrip()
    out_lines.append(new)

Path(sys.argv[2]).write_text("\n".join(out_lines) + "\n")
print(f"Wrote {len(out_lines)} lines (comments removed) to {sys.argv[2]}")
