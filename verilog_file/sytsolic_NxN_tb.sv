module systolic_NxN_tb;

parameter N=8 , K=12;

logic clk, rst_n;

logic wsbn, csbn;
logic [63:0] wdata, rdata, data_shift;
logic [11:0] waddr, raddr;

logic start, clear, calc_done, dout_done, out_mode;
logic [7:0] k_param;
logic  [N-1:0] [19:0] row_out, col_out;


initial begin
    clk = 0;
    rst_n = 0;
    wsbn = 1;
    wdata = 0;
    start = 0;
    clear = 0;
    k_param = K;
    out_mode = 1;
    #30;
    rst_n = 1;
    #25;
    start = 1;
    #25;
    start = 0;
    #1000;
    clear = 1;
    #25;
    clear = 0;
    #1000;
    $stop;
end

always#10 clk = ~clk;

sram_4k_64b #(.INIT("D:/temp/a.dat"))
u_sram_a (
    .clk(clk),
    .wsbn(wsbn),
    .waddr(waddr+N*K),
    .wdata(wdata),
    .csbn(csbn),
    .raddr(raddr),
    .rdata(rdata)
);

logic ren_n, wen_n;

shift_array #(.N(N))
u_shift_array (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(rdata),
    .ren_n(ren_n),
    .data_out(data_shift)
);

assign csbn = wen_n & ren_n;
assign wsbn = wen_n;

systolic_NxN #(.N(N))
u_systolic (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .clear(clear),
    .calc_done(calc_done),
    .dout_done(dout_done),
    .k_param(k_param),
    .out_mode(out_mode),
    .row_in(data_shift),
    .col_in(data_shift),
    .raddr(raddr),
    .ren_n(ren_n),
    .waddr(waddr),
    .wen_n(wen_n),
    .row_out(row_out),
    .col_out(col_out)
);

endmodule