import sys

def convert_to_meminit(input_file, output_file, word_size=8):
    """
    Convert a continuous hex stream into $readmemh format.
    
    input_file  : text file containing continuous hex (possibly with newlines)
    output_file : destination .hex file
    word_size   : number of hex digits per word (8 = 32 bits)
    """
    # Read and strip newlines/spaces
    with open(input_file, "r") as f:
        raw_hex = f.read().replace("\n", "").replace(" ", "")

    # Ensure length is multiple of word_size
    if len(raw_hex) % word_size != 0:
        print(f"⚠️ Warning: input length {len(raw_hex)} is not a multiple of {word_size}.")
        raw_hex = raw_hex[:len(raw_hex) - (len(raw_hex) % word_size)]

    # Split into chunks
    chunks = [raw_hex[i:i+word_size] for i in range(0, len(raw_hex), word_size)]

    # Write out one chunk per line
    with open(output_file, "w") as f:
        for c in chunks:
            f.write(c + "\n")

    print(f"✅ Wrote {len(chunks)} words to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python make_meminit.py <input_file> <output_file> [word_size_hex_digits]")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        word_size = int(sys.argv[3]) if len(sys.argv) > 3 else 8
        convert_to_meminit(input_file, output_file, word_size)
