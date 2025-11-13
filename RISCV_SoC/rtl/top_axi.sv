module top_axi (
    input  logic clk,
    input  logic resetn
);
//---------declarations---------
    // Native PicoRV32 memory interface
    wire        mem_valid;
    wire        mem_instr;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire [31:0] mem_rdata;
    wire        mem_ready;

    // AXI4-Lite master interface signals
    wire        mem_axi_awvalid;
    wire        mem_axi_awready;
    wire [31:0] mem_axi_awaddr;
    wire [2:0]  mem_axi_awprot;

    wire        mem_axi_wvalid;
    wire        mem_axi_wready;
    wire [31:0] mem_axi_wdata;
    wire [3:0]  mem_axi_wstrb;

    wire        mem_axi_bvalid;
    wire        mem_axi_bready;

    wire        mem_axi_arvalid;
    wire        mem_axi_arready;
    wire [31:0] mem_axi_araddr;
    wire [2:0]  mem_axi_arprot;

    wire        mem_axi_rvalid;
    wire        mem_axi_rready;
    wire [31:0] mem_axi_rdata;

//---------instantiations---------
    // PicoRV32 core
    picorv32 core (
        .clk        (clk),
        .resetn     (resetn),
        .mem_valid  (mem_valid),
        .mem_instr  (mem_instr),
        .mem_ready  (mem_ready),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_wstrb  (mem_wstrb),
        .mem_rdata  (mem_rdata)
    );

    // PicoRV32 AXI adapter
    picorv32_axi_adapter axi_adapter (
        // Native interface
        .clk        (clk),
        .resetn     (resetn),
        .mem_valid  (mem_valid),
        .mem_instr  (mem_instr),
        .mem_ready  (mem_ready),
        .mem_addr   (mem_addr),
        .mem_wdata  (mem_wdata),
        .mem_wstrb  (mem_wstrb),
        .mem_rdata  (mem_rdata),

        // AXI interface
            //Write Address Channel
        .mem_axi_awvalid (mem_axi_awvalid),
        .mem_axi_awready (mem_axi_awready),
        .mem_axi_awaddr  (mem_axi_awaddr),
        .mem_axi_awprot  (mem_axi_awprot),
            //Write Data Channel
        .mem_axi_wvalid  (mem_axi_wvalid),
        .mem_axi_wready  (mem_axi_wready),
        .mem_axi_wdata   (mem_axi_wdata),
        .mem_axi_wstrb   (mem_axi_wstrb),
            //Write Response Channel
        .mem_axi_bvalid  (mem_axi_bvalid),
        .mem_axi_bready  (mem_axi_bready),
            //Read Address Channel
        .mem_axi_arvalid (mem_axi_arvalid),
        .mem_axi_arready (mem_axi_arready),
        .mem_axi_araddr  (mem_axi_araddr),
        .mem_axi_arprot  (mem_axi_arprot),
            //Read Data Channel
        .mem_axi_rvalid  (mem_axi_rvalid),
        .mem_axi_rready  (mem_axi_rready),
        .mem_axi_rdata   (mem_axi_rdata)
    );

    simple_mem_axi mem (
        .clk        (clk),
        .resetn     (resetn),

        // AXI interface
            //Write Address Channel
        .mem_axi_awvalid (mem_axi_awvalid),
        .mem_axi_awready (mem_axi_awready),
        .mem_axi_awaddr  (mem_axi_awaddr),
        .mem_axi_awprot  (mem_axi_awprot),
            //Write Data Channel
        .mem_axi_wvalid  (mem_axi_wvalid),
        .mem_axi_wready  (mem_axi_wready),
        .mem_axi_wdata   (mem_axi_wdata),
        .mem_axi_wstrb   (mem_axi_wstrb),
            //Write Response Channel
        .mem_axi_bvalid  (mem_axi_bvalid),
        .mem_axi_bready  (mem_axi_bready),
            //Read Address Channel
        .mem_axi_arvalid (mem_axi_arvalid),
        .mem_axi_arready (mem_axi_arready),
        .mem_axi_araddr  (mem_axi_araddr),
        .mem_axi_arprot  (mem_axi_arprot),
            //Read Data Channel
        .mem_axi_rvalid  (mem_axi_rvalid),
        .mem_axi_rready  (mem_axi_rready),
        .mem_axi_rdata   (mem_axi_rdata)
    );

endmodule
