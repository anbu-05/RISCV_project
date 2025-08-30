from riscv_assembler.convert import AssemblyConverter as AC

conv = AC(output_mode='a', hex_mode=True)
hex_lines = conv("input/example_program_3.s")

# Remove '0x' prefix from each line
hex_lines_no_prefix = [line[2:] if line.startswith('0x') else line for line in hex_lines]

# Write to output file
with open("output/example_program_3.hex", "w") as f:
    for line in hex_lines_no_prefix:
        f.write(line + "\n")
