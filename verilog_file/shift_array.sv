module shift_array #(
    parameter N = 8
) (
    input clk,
    input rst_n,

    input logic [N-1:0] [7:0] data_in, // SA<->SRAM
    input logic ren_n,
    output logic [N-1:0] [7:0]  data_out

);

    logic ren_n_r;

    always_ff @ (posedge clk) begin
        ren_n_r <= ren_n;
    end

    assign data_out[0] = data_in[0];

    generate
        for (genvar i=1;i<N;i++) begin
            shift_register #(.LEN(i))
            u_shift_reg (
                .clk(clk),
                .rst_n(rst_n),
                .din(data_in[i]),
                .ren_n(ren_n_r),
                .dout(data_out[i])
            );
        end
    endgenerate
    
endmodule