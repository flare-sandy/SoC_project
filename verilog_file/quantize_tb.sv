
module quantize_tb ();

parameter INPUT_DW = 23;
parameter INPUT_IT = 16;
parameter INPUT_PC = 6;

parameter OUTPUT_DW = 8;
parameter OUTPUT_IT = 4;
parameter OUTPUT_PC = 3;

logic signed [INPUT_DW-1:0] data;
logic signed [OUTPUT_DW-1:0] quantized_data;
logic signed [INPUT_DW-1:0] ori_data;

initial begin
	data = 23'b11111111111111101010111;
	ori_data = data>>>2;
	#5
	data = 23'b00000000000001000001011;
	ori_data = data>>>2;
	#5
	data = 23'b11111111111100111111110;
	ori_data = data>>>2;
	#5
	data = 23'b00000000000000011100100;
	ori_data = data>>>2;		
end

quantize u_quan(
	.ori_data(ori_data),
	.quantized_data(quantized_data)
);

endmodule

