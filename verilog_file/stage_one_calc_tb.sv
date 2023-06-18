module stage_one_calc_tb;

parameter K=96, ROW=4, COL=12;

logic clk, rst_n;
logic start_all, out_mode, done_all;
logic [7:0] k_param, row_shape, col_shape;

initial begin
    clk = 0;
    rst_n = 0;
    k_param = K;
    out_mode = 1;
    start_all = 0;
    row_shape = ROW;
    col_shape = COL;
    #30;
    rst_n = 1;
    #25;
    start_all = 1;
    #25;
    start_all = 0;
    #200000;
    $finish;
end

always#10 clk = ~clk;

stage_one_calc #()
u_stage_one_calc (
    .clk(clk),
    .rst_n(rst_n),

    .start_all(start_all),
    .k_param(k_param),
    .out_mode(out_mode),
    .row_shape(row_shape),
    .col_shape(col_shape),
    .done_all(done_all)
);

endmodule