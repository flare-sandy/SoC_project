module mul #(
    parameter in_DW  = 8,
    parameter out_DW = 16
)
(
    input  logic clk,
    input  logic rst_n,
    input  logic signed [in_DW-1:0]  ina,
    input  logic signed [in_DW-1:0]  inb,
    output logic signed [out_DW-1:0] out
);

// wire out_w;
// assign out_w = ina * inb;
assign out = ina * inb;

endmodule