module systolic_NxN_tb;

parameter N=4;

logic clk, rst_n;

logic wsbn, csbn;
logic [31:0] wdata, rdata;
logic [12:0] waddr, raddr;

logic start, clear, done;
logic [7:0] k_param;
logic  [N-1:0][N-1:0] [19:0] out;


initial begin
    clk = 0;
    rst_n = 0;
    wsbn = 1;
    wdata = 0;
    start = 0;
    clear = 0;
    k_param = 6;
    #30;
    rst_n = 1;
    #20;
    start = 1;
    #20;
    start = 0;
    #1000;
    $stop;
end

always#10 clk = ~clk;

sram_8k_32b #(.INIT("D:/temp/a.dat"))
u_sram_a (
    .clk(clk),
    .wsbn(wsbn),
    .wdata(wdata),
    .csbn(csbn),
    .raddr(raddr),
    .rdata(rdata)
);

systolic_NxN #(.N(N))
u_systolic (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .clear(clear),
    .done(done),
    .k_param(k_param),
    .data_a(rdata),
    .data_b(rdata),
    .addr(raddr),
    .rd_en_n(csbn),
    .out(out)
);

endmodule