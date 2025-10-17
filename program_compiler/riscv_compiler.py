#!/usr/bin/env python3
# asm2hex_simple.py — minimal .s -> .hex using riscv-assembler
import sys
from pathlib import Path
from riscv_assembler.convert import AssemblyConverter as AC

if len(sys.argv) < 2:
    print("Usage: python asm2hex_simple.py input.s [output.hex]")
    sys.exit(1)

in_path = Path(sys.argv[1])
out_path = Path(sys.argv[2]) if len(sys.argv) > 2 else in_path.with_suffix('.hex')

conv = AC(output_mode='a', hex_mode=True)   # matches the example you used
hex_lines = list(conv(str(in_path)))        # expects an iterable/list of hex strings

with out_path.open('w') as f:
    for h in hex_lines:
        h = h.strip()
        if h.startswith(('0x', '0X')):
            h = h[2:]
        f.write(h.lower().zfill(8) + "\n")

print(f"Wrote {len(hex_lines)} lines to {out_path}")
