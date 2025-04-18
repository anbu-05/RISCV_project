package TypesPkg;

	typedef enum logic [2:0] {R, I, B, J, U} inst_type_t;

	typedef enum logic [4:0] {ADD, SUB, SLL, SLT, XOR, SRL, SRA, OR, AND, 
							  ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI,
							  EQL, LT, GE} ALU_func_t;

	typedef enum logic [2:0] {
		addsub = 3'b000,
		sll    = 3'b001,
		slt    = 3'b010,
		xor_op = 3'b100,
		srlsra = 3'b101,
		or_op  = 3'b110,
		and_op = 3'b111
	} R_funct3_t;
	
	typedef enum logic [2:0] {
		addi   = 3'b000,
		slti   = 3'b010,
		xori   = 3'b100,
		ori    = 3'b110,
		andi   = 3'b111,
		slli   = 3'b001,
		srli_srai = 3'b101  // Distinguish by funct7[5]
	} I_funct3_t;
	
	typedef enum logic [2:0] {
    beq  = 3'b000,
    bne  = 3'b001,
    blt  = 3'b100,
    bge  = 3'b101
	} B_funct3_t;

endpackage
