# RISC-V CPU Core

This is a personal project where I’ve been building a RISC-V CPU core from scratch in SystemVerilog. It started as a class assignment and has evolved into a complete custom RISC-V core with both simulation and FPGA implementations.

---

## Current Status

The main development for this project has now moved to a dedicated branch focused entirely on the custom RISC-V core. The documentation there is more detailed and up to date.

**If you want to build, simulate, or modify the RISC-V core, switch to the following branch:**

```
branch: Basic_RISCV_core
```

You can find full setup instructions, simulation steps, compiler usage, and FPGA build notes directly in that branch’s `README.md` file.

---

## Overview (Main Branch)

This main branch currently contains the legacy setup and earlier work before the restructuring. It includes partial implementations and test versions from the original ModelSim and Quartus builds.

If you’re just exploring the history or earlier iterations of the design, you can browse the older directories here. For actual development or testing, use the **Basic_RISCV_core** branch.

---

## Migration Notes

* All new design files (`rtl`, `tb`, and compiler scripts) are maintained in the `Basic_RISCV_core` branch.
* This branch may still contain older non-synthesizable test modules and experimental code.
* The new branch unifies simulation and FPGA codebases, with a clear workflow using QuestaSim and Quartus.

---

## Quick Links

* Active development: [`Basic_RISCV_core` branch](https://github.com/anbu-05/RISCV_project/tree/Basic_RISCV_core)
* Old simulation example: [`others` branch](https://github.com/anbu-05/RISCV_project/tree/others)

---

## Summary

This branch is considered legacy. For all current and future development, please use the `Basic_RISCV_core` branch — it contains the latest README with updated setup instructions, directory structure, compiler details, and FPGA guidance.
