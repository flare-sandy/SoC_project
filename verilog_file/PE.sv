module PE #(
    parameter in_DW  = 8
)
(
    input  logic clk,
    input  logic rst_n,
    input  logic en,
    input  logic clc,
    input  logic [in_DW-1:0] in_left, in_up,
    output logic [in_DW-1:0] out_right, out_down,
    output logic [in_DW-1:0] result
    // output done;
);

    localparam out_DW = in_DW + 7;  // set according to # of accumulation

    logic signed [2*in_DW-1:0] product;
    logic  signed [out_DW-1:0] sum;

    logic signed [in_DW-1:0]  result_R_quan;
    logic signed [in_DW-1:0]  result_I_quan;

    always_ff @(posedge clk) begin
        if(!rst_n) begin
            out_right <= {in_DW{1'b0}};
            out_down  <= {in_DW{1'b0}};
            sum       <= {out_DW{1'b0}};
        end
        else if(en) begin
            out_right <= in_left;
            out_down  <= in_up;
            if(clc) begin   // start new calculation
                sum  <= product;
            end
            else begin      // MAC continues    
                sum  <= sum + product;
            end
        end
        else begin
            out_right <= {in_DW{1'b0}};
            out_down  <= {in_DW{1'b0}};
            sum       <= {out_DW{1'b0}};
        end
    end

    mul #(.in_DW(in_DW), .out_DW(2*in_DW)) u0_mul(
        .clk(clk),
        .rst_n(rst_n),
        .ina(in_left),
        .inb(in_up),
        .out(product)
    );

    quantize u0_quantize(
	.ori_data_R(sum),
	.quantized_data_R(result)
);

endmodule
