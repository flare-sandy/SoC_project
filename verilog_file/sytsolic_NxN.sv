module systolic_NxN
#(
    parameter N = 8
)(
    input clk,
    input rst_n,

    input logic start,
    input logic clear,
    output logic calc_done,
    output logic dout_done,

    input logic [7:0] k_param, // calculate Nxk mul kxN
    input logic out_mode, // 0:row out or 1:col out

    input logic signed [N-1:0] [7:0] row_in,
    input logic signed [N-1:0] [7:0] col_in,

    output logic [12:0] raddr,
    output logic [12:0] waddr,
    output logic ren_n, //active low
    output logic wen_n, //active low
    
    output logic signed [N-1:0] [23:0] row_out,
    output logic signed [N-1:0] [23:0] col_out
);

typedef struct {
    logic signed [7:0] a;
    logic signed [7:0] b;
    logic signed [23:0] psum;
} PE;

PE pe_array [0:N-1][0:N-1];

logic [7:0] cnt, shift_cnt, clear_cnt;

logic busy, shift_busy, calc_busy, calc_busy_r, clear_r;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 0;
    end 
    else begin
        if (start) begin
            cnt <= 0;
        end
        else if (busy) begin
            cnt <= cnt + 1;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_cnt <= 0;
    end
    else begin
        shift_cnt <= cnt;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        busy <= 0;
    end 
    else begin
        if (start) begin
            busy <= 1;
        end
        else if (cnt == 2*N+k_param-3) begin
            busy <= 0;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        shift_busy <= 0;
        calc_busy <= 0;
        calc_busy_r <= 0;
    end
    else begin
        shift_busy <= busy;
        calc_busy <= shift_busy;
        calc_busy_r <= calc_busy;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        calc_done <= 0;
    end
    else begin
        if (calc_busy_r && !calc_busy) begin
            calc_done <= 1;
        end
        else begin
            calc_done <= 0;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clear_r <= 0;
    end
    else begin
        if (clear) begin
            clear_r <= 1;
        end
        else if (clear_cnt == N-1) begin
            clear_r <= 0;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clear_cnt <= 0;
    end
    else begin
        if (clear_cnt == N-1) begin
            clear_cnt <= 0;
        end
        else if (clear_r) begin
            clear_cnt <= clear_cnt + 1;
        end
    end
end

assign dout_done = (clear_cnt == N-1) ? 1:0;

// data shift
always_ff @(posedge clk or negedge rst_n) begin: shift_reg
    if (!rst_n) begin
        for (int i=0;i<N;i++) begin
            for (int j=0;j<N;j++) begin
                pe_array[i][j].a <= 0;
                pe_array[i][j].b <= 0;
            end
        end
    end 
    else begin
        if (shift_busy) begin
            for (int i=0;i<N;i++) begin
                pe_array[i][0].a <= (shift_cnt>=i && shift_cnt<k_param+i) ? row_in[i]:0;
            end
            for (int j=0;j<N;j++) begin
                pe_array[0][j].b <= (shift_cnt>=j && shift_cnt<k_param+j) ? col_in[j]:0;
            end

            for (int i=0;i<N;i++) begin
                for (int j=1;j<N;j++) begin
                    pe_array[i][j].a <= pe_array[i][j-1].a;
                end
            end

            for (int j=0;j<N;j++) begin
                for (int i=1;i<N;i++) begin
                    pe_array[i][j].b <= pe_array[i-1][j].b;
                end
            end
        end
    end
end

// data MAC
always_ff @(posedge clk or negedge rst_n) begin: MAC_calc
    if (!rst_n) begin
        for (int i=0;i<N;i++) begin
            for (int j=0;j<N;j++) begin
                pe_array[i][j].psum <= 0;
            end
        end
    end
    else begin
        if (calc_busy) begin
            for (int i=0;i<N;i++) begin
                for (int j=0;j<N;j++) begin
                    pe_array[i][j].psum <= pe_array[i][j].a * pe_array[i][j].b + pe_array[i][j].psum; 
                end
            end
        end
        else if (clear_r) begin
            if (out_mode) begin
                for (int i=0;i<N;i++) begin
                    pe_array[i][N-1].psum <= 0;
                    for (int j=0;j<N-1;j++) begin
                        pe_array[i][j].psum <= pe_array[i][j+1].psum; 
                    end
                end
            end
            else begin
                for (int j=0;j<N;j++) begin
                    pe_array[N-1][j].psum <= 0;
                    for (int i=0;i<N-1;i++) begin
                        pe_array[i][j].psum <= pe_array[i+1][j].psum; 
                    end
                end
            end
        end
    end
end

assign raddr = (cnt<k_param) ? cnt:0;

assign ren_n = ((busy)&&(cnt<k_param)) ? 0:1;

always_comb begin: data_col_out
    for (int i=0;i<N;i++) begin
        col_out[i] = (out_mode) ? pe_array[i][0].psum:0;
    end
end

always_comb begin: data_row_out
    for (int j=0;j<N;j++) begin
        row_out[j] = (out_mode) ? 0:pe_array[0][j].psum;
    end
end

assign waddr = clear_cnt;
assign wen_n = ! clear_r;

endmodule