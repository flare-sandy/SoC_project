//-------ori data is from systolic array, output to quantized data, then to out_buffer-------
//quantize the data from 39 bit(13: integer, 26: precision) to 16 bit(8: integer, 8: precision)

module quantize #(
	parameter INPUT_DW = 24,
	parameter INPUT_IT = 17,
	parameter INPUT_PC = 6,

	parameter OUTPUT_DW = 8,
	parameter OUTPUT_IT = 4,
	parameter OUTPUT_PC = 3
)
(
	input  logic signed [INPUT_DW-1:0] ori_data,
	output logic signed [OUTPUT_DW-1:0] quantized_data
);
// [19:0] 20bits
logic signed [INPUT_IT+OUTPUT_PC:0] round; 
logic signed carry_bit;

// round for precision part
assign carry_bit = ori_data[INPUT_DW-1] ? ( ori_data[INPUT_PC-OUTPUT_PC-1] & (|ori_data[INPUT_PC-OUTPUT_PC-2:0]) ) : ori_data[INPUT_PC-OUTPUT_PC-1] ;
// ori_data[22], ori_data[22:3] + 0/1
assign round = {ori_data[INPUT_DW-1], ori_data[INPUT_DW-1:INPUT_PC-OUTPUT_PC]} + carry_bit;

// saturation for integer part
assign quantized_data = (round[(INPUT_IT+OUTPUT_PC) -: (INPUT_IT-OUTPUT_IT+1)] == {(INPUT_IT-OUTPUT_IT+1){1'b0}} ||
		round[(INPUT_IT+OUTPUT_PC) -: (INPUT_IT-OUTPUT_IT+1)] == {(INPUT_IT-OUTPUT_IT+1){1'b1}})
		? round[OUTPUT_DW-1:0]: // cut
		{round[INPUT_IT+OUTPUT_PC],{(OUTPUT_DW-1){!round[INPUT_IT+OUTPUT_PC]}}} ; // saturation

endmodule

