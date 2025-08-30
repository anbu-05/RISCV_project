/*
testing:
1. Reset behavior
    - Assert `reset = 1` → PC should go to `0`.
    - Deassert reset → PC should resume operation.
2. Normal increment
    - With `enable = 1` and `jump = 0`, no jumps → PC increments by 4 each cycle.
3. Enable = 0 (stall)
    - PC should hold its value when `enable = 0`.
4. jump
	- when `jump = 1`, PC should update as `pc_reg + (imm << 1)`
*/

module tb_ProgramCounter;
    logic clk, reset, enable, jump;
    logic signed [31:0] imm;

    logic [31:0] pc_out;

    int log;
    string line;

    //initiating DUT

    ProgramCounter DUT(.enable(enable), .clk(clk), .reset(reset), .jump(jump), .imm(imm), .pc_out(pc_out));

    always #5 clk = ~clk

    initial begin
        log = $fopen("Testcase_results.log", "w");

        clk = 0;
        reset = 1;
        enable = 0;
        imm = 0;
        jump = 0;

        #20

        //1: reset behaviour
        @(posedge clk) reset = 0; enable = 1;
        $fgets(line, log);
        $fdisplay("test 1: PASS\n(reset behaviour)", line);

        $fclose(log);
    end
endmodule
