//-------ori data is from systolic array, output to quantized data, then to out_buffer-------
//quantize the data from 39 bit(13: integer, 26: precision) to 16 bit(8: integer, 8: precision)

module quantize #(
	parameter ARRAY_SIZE = 1,

	parameter INPUT_DW = 39,
	parameter INPUT_IT = 13,
	parameter INPUT_PC = 26,

	parameter OUTPUT_DW = 16,
	parameter OUTPUT_IT = 8,
	parameter OUTPUT_PC = 8
)
(
	input  logic signed [ARRAY_SIZE*(INPUT_DW)-1:0] ori_data_R,
	output logic signed [ARRAY_SIZE*OUTPUT_DW-1:0] quantized_data_R
);
// [21:0] 22bits
logic [INPUT_IT+OUTPUT_PC:0] round_R; 
logic [INPUT_IT+OUTPUT_PC:0] round_I;
logic carry_bit_R;
logic carry_bit_I;

// round for precision part
assign carry_bit_R = ori_data_R[INPUT_DW-1] ? ( ori_data_R[INPUT_PC-OUTPUT_PC-1] & (|ori_data_R[INPUT_PC-OUTPUT_PC-2:0]) ) : ori_data_R[INPUT_PC-OUTPUT_PC-1] ;
// ori_data_R[38], ori_data_R[38:18] + 0/1
assign round_R = {ori_data_R[INPUT_DW-1], ori_data_R[INPUT_DW-1:INPUT_PC-OUTPUT_PC]} + carry_bit_R;

// saturation for integer part
assign quantized_data_R = (round_R[(INPUT_IT+OUTPUT_PC) -: (INPUT_IT-OUTPUT_IT+1)] == {(INPUT_IT-OUTPUT_IT+1){1'b0}} ||
		round_R[(INPUT_IT+OUTPUT_PC) -: (INPUT_IT-OUTPUT_IT+1)] == {(INPUT_IT-OUTPUT_IT+1){1'b1}})
		? round_R[OUTPUT_DW-1:0]:
		{round_R[INPUT_IT+OUTPUT_PC],{(OUTPUT_DW-1){!round_R[INPUT_IT+OUTPUT_PC]}}} ;

endmodule

