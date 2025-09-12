import TypesPkg::*;

module Decoder(
    input logic [31:0] instruction

    output logic [4:0] rd, rs1, rs2,
    output logic signed [31:0] imm,

    output inst_type_t
)