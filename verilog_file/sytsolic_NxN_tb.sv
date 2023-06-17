module systolic_NxN_tb;

parameter N=8;

logic clk, rst_n;

logic wsbn, csbn;
logic [63:0] wdata, rdata, data_shift;
logic [11:0] waddr, raddr;

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
    k_param = 12;
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

sram_4k_64b #(.INIT("D:/temp/a.dat"))
u_sram_a (
    .clk(clk),
    .wsbn(wsbn),
    .wdata(wdata),
    .csbn(csbn),
    .raddr(raddr),
    .rdata(rdata)
);

shift_array #(.N(N))
u_shift_array (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(rdata),
    .ren_n(csbn),
    .data_out(data_shift)
);

systolic_NxN #(.N(N))
u_systolic (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .clear(clear),
    .done(done),
    .k_param(k_param),
    .data_a(data_shift),
    .data_b(data_shift),
    .raddr(raddr),
    .ren_n(csbn),
    .waddr(),
    .wen_n(),
    .out(out)
);

endmodule