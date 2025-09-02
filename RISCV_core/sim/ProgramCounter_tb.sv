/*
#### ProgramCounter
1. Reset behavior
    - Assert `reset = 1` → PC should go to `0`.
    - Deassert reset → PC should resume operation.
2. Normal increment
    - With `enable = 1` and `jump = 0`, no jumps → PC increments by 4 each cycle.
3. Enable = 0 (stall)
    - PC should hold its value when `enable = 0`.
4. Jump
    - When `jump = 1`, PC should update as `pc_reg + (imm << 1)`.

advanced:
1. Negative `imm`
    - Since `imm` is signed, check that left shift works properly when `imm` is negative.
    - Example: if `imm = -2`, `(imm << 1) = -4`, so PC should subtract.
2. Jump + Stall interaction
    - Assert `jump = 1` but keep `enable = 0`.
    - Expected: PC should not move, even though a jump condition exists.
3. Multiple consecutive jumps
    - Set `jump = 1` for several cycles.
    - Verify it keeps accumulating `(imm << 1)` each cycle.
4. Reset during operation
    - While PC is mid-count (e.g., at `24`), assert reset.
    - Check PC snaps back to `0` immediately.
5. Boundary / wraparound
    - Drive PC near the 32-bit max (like `32'hFFFFFFFC`) and see what happens when incrementing.
    - Expected: it wraps around (overflow).
    - Even if you don’t need wraparound behavior, it’s good to know exactly what it does in simulation.
*/



module ProgramCounter_tb;
    logic clk, rst, en, jmp;
    logic signed [31:0] imm;

    logic [31:0] pc_out;

    int log;
    string line;

    //initiating DUT

    ProgramCounter dut(.en(en), .clk(clk), .rst(rst), .jmp(jmp), .imm(imm), .pc_out(pc_out));

    task check(input string testname, input logic [31:0] expected);
        if (pc_out == expected) $fdisplay(log, "%0t : [PASS] %s | PC = %0d", $time, testname, pc_out);
        else $fdisplay(log, "%0t : [FAIL] %s | expected = %0d, PC = %0d", $time, testname, expected, pc_out);
    endtask

    always #5 clk = ~clk;

    initial begin
        log = $fopen("sim/Testcase_results.log", "w");

        clk = 0;
        rst = 1;
        en = 0;
        imm = 0;
        jmp = 0;

        //1: rst behaviour
        @(posedge clk) rst = 0; en = 1;
       ; #1; check("test 1: rst behaviour", 32'd0);

        //2: normal increment
        @(posedge clk); #1; check("normal increment 1", 32'd4);
        @(posedge clk); #1; check("normal increment 2", 32'd8);
        
        //3: stall
        en = 0;
        @(posedge clk); #1; check("stall on clock cycle 1", 32'd8);
        @(posedge clk); #1; check("stall on clock cycle 2", 32'd8);
        en = 1;

        //4: jmp with positive imm
        imm = 4; jmp = 1; //(imm << 1) = 8
        @(posedge clk); #1; check("jmp forward imm=4", 32'd16);

        //5: jmp with negative imm
        imm = -2; jmp = 1; //(imm << 1) = 4
        @(posedge clk); #1; check("jmp forward imm=-2", 32'd12);

        //6: jmp+stall
        en = 0;
        imm = 10; jmp = 1; //(imm << 1) = 8
        @(posedge clk); #1; check("jmp+stall", 32'd12);
        en = 1; jmp = 0;

        //7: multiple consecutive jmps
        imm = 1; jmp = 1; //adds 2 on each cycle
        @(posedge clk); #1; check("consecutive jmp 1", 32'd14);
        @(posedge clk); #1; check("consecutive jmp 2", 32'd16);
        jmp = 0;

        //8: rst during operation
        #2
        rst = 1;
        @(posedge clk); #1; check("reset mid operation (after 2ps of clk cycle)", 32'd0);
        rst = 0;

        //9: wraparound
        pc_out = 32'hFFFFFFFC;
        dut.pc_reg = 32'hFFFFFFFC;
        @(posedge clk); #1; check("wraparound", 32'd0);

        $fclose(log);
    end
endmodule
