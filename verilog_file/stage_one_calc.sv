module stage_one_calc #(
    parameter N = 8,
    parameter INIT_INPUT = "D:/temp/input.dat",
    parameter INIT_WQ = "D:/temp/wq.dat"
) (
    input clk,
    input rst_n,
    
    input logic start_all,
    input logic [7:0] k_param,
    input logic out_mode,
    input logic [7:0] row_shape, // N*row_shape = row_num
    input logic [7:0] col_shape, // N*col_shape = col_num
    output logic done_all
);

logic ren_n, wen_n;
logic [63:0] rdata_input, rdata_wq, shift_input, shift_wq;
logic [12:0] raddr, raddr_input, raddr_wq, waddr;

logic [191:0] row_out, col_out;

sram_4k_64b #(.INIT(INIT_INPUT))
u_sram_input (
    .clk(clk),
    .wsbn(1'b1),
    .waddr('b0),
    .wdata('b0),
    .csbn(ren_n),
    .raddr(raddr_input),
    .rdata(rdata_input)
);

shift_array #(.N(N))
u_shift_array_row (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(rdata_input),
    .ren_n(ren_n),
    .data_out(shift_input)
);

sram_4k_64b #(.INIT(INIT_WQ))
u_sram_wq (
    .clk(clk),
    .wsbn(1'b1),
    .waddr('b0),
    .wdata('b0),
    .csbn(ren_n),
    .raddr(raddr_wq),
    .rdata(rdata_wq)
);

shift_array #(.N(N))
u_shift_array_col (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(rdata_wq),
    .ren_n(ren_n),
    .data_out(shift_wq)
);

logic start, clear, calc_done, dout_done;


assign start = (start_all || (dout_done && !done_all)) ? 1:0;
assign clear = calc_done;

logic [7:0] row_cnt, col_cnt;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        row_cnt <= 0;
        col_cnt <= 0;
    end
    else begin
        if (dout_done) begin
            if (col_cnt == col_shape-1) begin
                col_cnt <= 0;
                if (row_cnt == row_shape-1) begin
                    row_cnt <= 0;
                end
                else begin
                    row_cnt <= row_cnt + 1;
                end
            end
            else begin
                col_cnt <= col_cnt + 1;
            end
        end
    end
end

assign done_all = ((row_cnt == row_shape-1) && (col_cnt == col_shape-1)) ? dout_done:0;

assign raddr_input = row_cnt * k_param + raddr;
assign raddr_wq = col_cnt * k_param + raddr;

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
    .row_in(shift_input),
    .col_in(shift_wq),
    .raddr(raddr),
    .ren_n(ren_n),
    .waddr(waddr),
    .wen_n(wen_n),
    .row_out(row_out),
    .col_out(col_out)
);

logic csbn_wk;
assign csbn_wk = wen_n;

sram_4k_192b #(.INIT(""))
u_sram_k (
    .clk(clk),
    .wsbn(wen_n),
    .waddr(waddr),
    .wdata(col_out),
    .csbn(csbn_wk),
    .raddr(),
    .rdata()
);
    
endmodule