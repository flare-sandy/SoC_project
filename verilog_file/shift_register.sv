module shift_register #(
    parameter LEN = 4
)(
    input clk,
    input rst_n,

    input [7:0] din,
    input logic ren_n,
    output logic [7:0] dout
);

    logic [7:0] shift_reg [0:LEN-1];

    always_ff @(posedge clk) begin
        for (int i=0;i<LEN;i++) begin
            if (i==0) begin
                if (!rst_n) begin
                    shift_reg[i] <= 0;
                end
                else begin
                    if (ren_n) begin
                        shift_reg[i] <= 0;
                    end
                    else begin
                        shift_reg[i] <= din;
                    end
                end
            end
            else begin
                if (!rst_n) begin
                    shift_reg[i] <= 0;
                end
                else begin
                    shift_reg[i] <= shift_reg[i-1];
                end
            end
        end
    end

    assign dout = shift_reg[LEN-1];

endmodule