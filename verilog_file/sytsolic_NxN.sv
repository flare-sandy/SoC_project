module systolic_NxN
#(
    parameter N = 8
)(
    input clk,
    input rst_n,

    input logic start,
    input logic clear,
    output logic done,

    input logic [7:0] k_param, // calculate Nxk mul kxN

    input logic [N-1:0] [7:0] data_a,
    input logic [N-1:0] [7:0] data_b,

    output logic [12:0] addr,
    output logic rd_en_n, //active low
    output logic valid,
    
    output logic [N-1:0] [N-1:0] [19:0] out
);

typedef struct {
    logic [7:0] a;
    logic [7:0] b;
    logic [19:0] psum;
} PE;

PE pe_array [0:N-1][0:N-1];

logic [7:0] cnt, shift_cnt;

logic busy, shift_busy, calc_busy, calc_busy_r;

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
        done <= 0;
    end
    else begin
        if (calc_busy_r && !calc_busy) begin
            done <= 1;
        end
        else begin
            done <= 0;
        end
    end
end

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
                pe_array[i][0].a <= (shift_cnt>=i && shift_cnt<k_param+i) ? data_a[i]:0;
            end
            for (int j=0;j<N;j++) begin
                pe_array[0][j].b <= (shift_cnt>=j && shift_cnt<k_param+j) ? data_b[j]:0;
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
        else if (clear) begin
            for (int i=0;i<N;i++) begin
                for (int j=0;j<N;j++) begin
                    pe_array[i][j].psum <= 0; 
                end
            end
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid <= 0;
    end 
    else begin
        if (start || clear) begin
            valid <= 0;
        end
        else if (cnt == N+k_param+1) begin
            valid <= 1;
        end
    end
end

assign addr = (cnt<k_param) ? cnt:(cnt<k_param+N-1) ? cnt-k_param:0;

assign rd_en_n = ((busy)&&(cnt<k_param+N-1)) ? 0:1;

always_comb begin: data_out
    for (int i=0;i<N;i++) begin
        for (int j=0;j<N;j++) begin
            out[i][j]=pe_array[i][j].psum;
        end
    end
end

endmodule