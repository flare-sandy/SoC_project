
`define INPUT_ADDR     12'h000  // 32*96/8=384
`define WQ0_ADDR       12'h180  // 96*48/8=576，384+576=960
`define WQ1_ADDR       12'h3C0  // 96*48/8=576，960+576=1536
`define WK0_ADDR       12'h600  // 96*48/8=576，1536+576=2112
`define WK1_ADDR       12'h840  // 96*48/8=576，2112+576=2688
`define WV0_ADDR       12'hA80  // 96*48/8=576，2688+576=3264
`define WV1_ADDR       12'hCC0  // 96*48/8=576，3264+576=3840(0xF00)
`define CONTROL_ADDR   12'hF00
`define STATUS_ADDR    12'hF04


module icb_slave_tb();
    // clk & rst_n
    logic             clk;
    logic             rst_n;

    // icb bus
    logic             icb_cmd_valid;
    logic             icb_cmd_ready;
    logic             icb_cmd_read;
    logic     [31:0]  icb_cmd_addr;
    logic     [31:0]  icb_cmd_wdata;
    logic     [3:0]   icb_cmd_wmask;

    logic             icb_rsp_valid;
    logic             icb_rsp_ready;
    logic     [31:0]  icb_rsp_rdata;
    logic             icb_rsp_err;

    // reg output
    logic             wsbn_sram_input;
    logic    [11:0]   waddr_sram_input;
    logic    [63:0]   wdata_sram_input;
 
    logic             wsbn_sram_wq0;
    logic    [11:0]   waddr_sram_wq0;
    logic    [63:0]   wdata_sram_wq0;
 
    logic             wsbn_sram_wq1;
    logic    [11:0]   waddr_sram_wq1;
    logic    [63:0]   wdata_sram_wq1;
 
    logic             wsbn_sram_wk0;
    logic    [11:0]   waddr_sram_wk0;
    logic    [63:0]   wdata_sram_wk0;
 
    logic             wsbn_sram_wk1;
    logic    [11:0]   waddr_sram_wk1;
    logic    [63:0]   wdata_sram_wk1;
 
    logic             wsbn_sram_wv0;
    logic    [11:0]   waddr_sram_wv0;
    logic    [63:0]   wdata_sram_wv0;
 
    logic             wsbn_sram_wv1;
    logic    [11:0]   waddr_sram_wv1;
    logic    [63:0]   wdata_sram_wv1;
 
    logic             csbn_sram_output;
    logic    [11:0]   raddr_sram_output;
    logic    [63:0]   rdata_sram_output;
 
    logic    [31:0]   CONTROL;
    logic    [31:0]   STATUS;

always #10 clk = ~clk;

initial begin
    clk   = 0;
    rst_n = 0;
    #20
    rst_n = 1;
    #10
    icb_cmd_valid = 1;
    icb_cmd_read  = 0;
    icb_cmd_addr  = 32'h1004_2000;
    icb_cmd_wdata = 32'h1100_0011;
    #40
    rst_n = 1;
    icb_cmd_valid = 1;
    icb_cmd_read  = 0;
    icb_cmd_addr  = 32'h1004_2000;
    icb_cmd_wdata = 32'h0000_1111;
    #40
    rst_n = 1;
    icb_cmd_valid = 1;
    icb_cmd_read  = 0;
    icb_cmd_addr  = 32'h1004_2600;
    icb_cmd_wdata = 32'h0000_1111;
    #40
    rst_n = 1;
    icb_cmd_valid = 1;
    icb_cmd_read  = 0;
    icb_cmd_addr  = 32'h1004_2600;
    icb_cmd_wdata = 32'h1111_1111;
    #40
    rst_n = 1;
    icb_cmd_valid = 1;
    icb_cmd_read  = 0;
    icb_cmd_addr  = 32'h1004_2601;
    icb_cmd_wdata = 32'h1000_1111;
    #40
    rst_n = 1;
    icb_cmd_valid = 1;
    icb_cmd_read  = 0;
    icb_cmd_addr  = 32'h1004_2601;
    icb_cmd_wdata = 32'h0000_1111;
    #40
    rst_n = 1;
    icb_cmd_valid = 1;
    icb_cmd_read  = 0;
    icb_cmd_addr  = 32'h1004_2602;
    icb_cmd_wdata = 32'h0111_1000;
    #40
    rst_n = 1;
    icb_cmd_valid = 1;
    icb_cmd_read  = 0;
    icb_cmd_addr  = 32'h1004_2602;
    icb_cmd_wdata = 32'h1010_0101;
    #40
    rst_n = 1;
    icb_cmd_valid = 1;
    icb_cmd_read  = 0;
    icb_cmd_addr  = 32'h1004_2603;
    icb_cmd_wdata = 32'h1010_1111;
    #40
    rst_n = 1;
    icb_cmd_valid = 1;
    icb_cmd_read  = 0;
    icb_cmd_addr  = 32'h1004_2603;
    icb_cmd_wdata = 32'h0000_1011;
    #40
    rst_n = 1;
    icb_cmd_valid = 1;
    icb_cmd_read  = 0;
    icb_cmd_addr  = 32'h1004_2604;
    icb_cmd_wdata = 32'h0110_1001;
    #40
    rst_n = 1;
    icb_cmd_valid = 1;
    icb_cmd_read  = 0;
    icb_cmd_addr  = 32'h1004_2604;
    icb_cmd_wdata = 32'h1000_1111;

end

icb_slave icb(
    .clk(clk),
    .rst_n(rst_n),
    .icb_cmd_valid(icb_cmd_valid),
    .icb_cmd_ready(icb_cmd_ready),
    .icb_cmd_read(icb_cmd_read),
    .icb_cmd_addr(icb_cmd_addr),
    .icb_cmd_wdata(icb_cmd_wdata),
    .icb_cmd_wmask(icb_cmd_wmask),
    .icb_rsp_valid(icb_rsp_valid),
    .icb_rsp_ready(icb_rsp_ready),
    .icb_rsp_rdata(icb_rsp_rdata),
    .icb_rsp_err(icb_rsp_err),
    .wsbn_sram_input(wsbn_sram_input),
    .waddr_sram_input(waddr_sram_input),
    .wdata_sram_input(wdata_sram_input),
    .wsbn_sram_wq0(wsbn_sram_wq0),
    .waddr_sram_wq0(waddr_sram_wq0),
    .wdata_sram_wq0(wdata_sram_wq0),
    .wsbn_sram_wq1(wsbn_sram_wq1),
    .waddr_sram_wq1(waddr_sram_wq1),
    .wdata_sram_wq1(wdata_sram_wq1),
    .wsbn_sram_wk0(wsbn_sram_wk0),
    .waddr_sram_wk0(waddr_sram_wk0),
    .wdata_sram_wk0(wdata_sram_wk0),
    .wsbn_sram_wk1(wsbn_sram_wk1),
    .waddr_sram_wk1(waddr_sram_wk1),
    .wdata_sram_wk1(wdata_sram_wk1),
    .wsbn_sram_wv0(wsbn_sram_wv0),
    .waddr_sram_wv0(waddr_sram_wv0),
    .wdata_sram_wv0(wdata_sram_wv0),
    .wsbn_sram_wv1(wsbn_sram_wv1),
    .waddr_sram_wv1(waddr_sram_wv1),
    .wdata_sram_wv1(wdata_sram_wv1),
    .csbn_sram_output(csbn_sram_output),
    .raddr_sram_output(raddr_sram_output),
    .rdata_sram_output(rdata_sram_output),
    .CONTROL(CONTROL),
    .STATUS(STATUS)
);


sram_4k_64b sram_input(
    .clk(clk),
    // write port
    .wsbn(wsbn_sram_input), //write enable, active low
    .waddr(waddr_sram_input),
    .wdata(wdata_sram_input),

    //read port
    .csbn(csbn_sram_output), //read enable, active low
    .raddr(raddr_sram_output),
    .rdata(rdata_sram_output)
);

sram_4k_64b sram_wq0(
    .clk(clk),
    // write port
    .wsbn(wsbn_sram_wq0), //write enable, active low
    .waddr(waddr_sram_wq0),
    .wdata(wdata_sram_wq0),

    //read port
    .csbn(1'b0), //read enable, active low
    .raddr(),
    .rdata()
);

sram_4k_64b sram_wq1(
    .clk(clk),
    // write port
    .wsbn(wsbn_sram_wq1), //write enable, active low
    .waddr(waddr_sram_wq1),
    .wdata(wdata_sram_wq1),

    //read port
    .csbn(1'b0), //read enable, active low
    .raddr(),
    .rdata()
);

sram_4k_64b sram_wk0(
    .clk(clk),
    // write port
    .wsbn(wsbn_sram_wk0), //write enable, active low
    .waddr(waddr_sram_wk0),
    .wdata(wdata_sram_wk0),

    //read port
    .csbn(1'b0), //read enable, active low
    .raddr(),
    .rdata()
);

sram_4k_64b sram_wk1(
    .clk(clk),
    // write port
    .wsbn(wsbn_sram_wk1), //write enable, active low
    .waddr(waddr_sram_wk1),
    .wdata(wdata_sram_wk1),

    //read port
    .csbn(1'b0), //read enable, active low
    .raddr(),
    .rdata()
);

sram_4k_64b sram_wv0(
    .clk(clk),
    // write port
    .wsbn(wsbn_sram_wv0), //write enable, active low
    .waddr(waddr_sram_wv0),
    .wdata(wdata_sram_wv0),

    //read port
    .csbn(1'b0), //read enable, active low
    .raddr(),
    .rdata()
);

sram_4k_64b sram_wv1(
    .clk(clk),
    // write port
    .wsbn(wsbn_sram_wv1), //write enable, active low
    .waddr(waddr_sram_wv1),
    .wdata(wdata_sram_wv1),

    //read port
    .csbn(1'b0), //read enable, active low
    .raddr(),
    .rdata()
);


endmodule
