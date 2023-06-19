module SA_with_shift_cfg #(
    parameter N = 8
) (
    input clk,
    input rst_n,
    
    // ctrl signal
    input  logic start_all,
    input  logic [7:0] k_param,
    input  logic out_mode, // 0 for row out, 1 for col out
    input  logic [7:0] row_shape, // out_mode=1:row out_mode=0:col
    input  logic [7:0] col_shape, // out_mode=1:col out_mode=0:row
    output logic done_all,

    // SRAM read & write
    output logic ren_n,

    output logic [11:0] raddr_row,
    input  logic [63:0] rdata_row,

    output logic [11:0] raddr_col,
    input  logic [63:0] rdata_col,

    output logic wen_n,
    output logic [12:0] waddr,

    output logic [N-1:0] [7:0] data_out

);

logic [N-1:0] [7:0] shift_row, shift_wq;
logic [12:0] raddr, raddr_input, raddr_wq;
logic [N-1:0] [23:0] sytsolic_out;
logic [7:0] a_shape, b_shape;

assign a_shape = out_mode ? col_shape:row_shape;
assign b_shape = out_mode ? row_shape:col_shape;

shift_array #(.N(N))
u_shift_array_row (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(rdata_row),
    .ren_n(ren_n),
    .data_out(shift_row)
);

shift_array #(.N(N))
u_shift_array_col (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(rdata_col),
    .ren_n(ren_n),
    .data_out(shift_col)
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
            if (col_cnt == b_shape-1) begin
                col_cnt <= 0;
                if (row_cnt == a_shape-1) begin
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

assign done_all = ((row_cnt == a_shape-1) && (col_cnt == b_shape-1)) ? dout_done:0;

assign raddr_row = out_mode ? col_cnt * k_param + raddr:row_cnt * k_param + raddr;
assign raddr_col = out_mode ? row_cnt * k_param + raddr:col_cnt * k_param + raddr;

logic [N-1:0] [7:0] temp_out, row_out, col_out;

systolic_NxN_cfg #(.N(N))
u_systolic (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .clear(clear),
    .calc_done(calc_done),
    .dout_done(dout_done),
    .k_param(k_param),
    .out_mode(out_mode),
    .row_in(shift_row),
    .col_in(shift_col),
    .raddr(raddr),
    .ren_n(ren_n),
    .waddr(waddr),
    .wen_n(wen_n),
    .row_out(row_out),
    .col_out(col_out)
);

assign temp_out = out_mode? col_out:row_out;

generate
    for (genvar i=0;i<N;i++) begin
        quantize u_quant_row (
            .ori_data(temp_out[i]),
            .quantized_data(data_out[i])
        );
    end
endgenerate
    
endmodule