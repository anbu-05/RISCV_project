# RISCV SoC (based on picorv32)
this is an SoC built around the picorv32 core. it is currently in development

## Overview

Main directory: `/RISCV_SoC/`

Folder structure:

```
/RISCV_SoC/
├─ RISCV_core/           # Main CPU design
│  ├─ programs/          # hex files to be loaded onto memory
│  ├─ rtl/               # Design (ALU, RegisterFile, Decoder, etc.)
│  ├─ tb/                # Testbench files
│  └─ sim/               # Questa simulation setup (run.do and configs)
├─ README.md
└─ old/                  # older work files
```

The core is designed to work with Intel/Altera QuestaSim.