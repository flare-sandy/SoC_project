module SA #(
    parameter data_width = 8,
    parameter num_row = 16,
    parameter num_col = 16
)
(
    input  logic clk,
    input  logic rst_n,
    input  logic en,
    input  logic clc       [num_row:1][num_col:1],
    input  logic [data_width-1:0]  row_in  [num_row:1],
    input  logic [data_width-1:0]  col_in  [num_col:1],
    input  logic [num_row:1]       row_out_valid,
    output logic [data_width-1:0]  row_out [num_col:1]
);

    logic [data_width-1:0] shift_right [num_row:1][num_col:1];  // vertical net between PE 
    logic [data_width-1:0] shift_down  [num_row:1][num_col:1];  // horizontal net between PE
    // DATAWIDTH ???
    logic [data_width-1:0] sum         [num_row:1][num_col:1];  // net of results in PE
    logic [data_width-1:0] sum_R       [num_row:1][num_col:1];  // store results in PE when it finishs its calculation;

/*
    //            e.g.  num_row = num_col = 8
    // 
    //       col8 col7 col6 col5 col4 col3 col2 col1
    // row8 | PE | PE | PE | PE | PE | PE | PE | PE |
    // row7 | PE | PE | PE | PE | PE | PE | PE | PE |
    // row6 | PE | PE | PE | PE | PE | PE | PE | PE |
    // row5 | PE | PE | PE | PE | PE | PE | PE | PE |
    // row4 | PE | PE | PE | PE | PE | PE | PE | PE |
    // row3 | PE | PE | PE | PE | PE | PE | PE | PE |
    // row2 | PE | PE | PE | PE | PE | PE | PE | PE |
    // row1 | PE | PE | PE | PE | PE | PE | PE | PE |
*/
    genvar row, col;
    generate
        for(row = num_row; row > 0; row = row-1) begin
            for (col = num_col; col > 0; col = col-1) begin
                if((row == num_row) && (col == num_col)) begin  // the first PE, both data from row_in and col_in
                    PE #(.in_DW(data_width)) PE_unit(
                        .clk(clk), 
                        .rst_n(rst_n),
                        .en(en), 
                        .clc(clc[num_row][num_col]),
                        .in_left(row_in[num_row]), 
                        .in_up(col_in[num_col]), 
                        .out_right(shift_right[num_row][num_col]), 
                        .out_down(shift_down[num_row][num_col]), 
                        .result(sum[num_row][num_col])
                    );                  
                end
                else if (row == num_row) begin                // PE placed in first row, up data from col_in
                    PE #(.in_DW(data_width)) PE_unit(
                        .clk(clk), 
                        .rst_n(rst_n),
                        .en(en), 
                        .clc(clc[row][col]),
                        .in_left(shift_right[row][col+1]), 
                        .in_up(col_in[col]), 
                        .out_right(shift_right[row][col]), 
                        .out_down(shift_down[row][col]), 
                        .result(sum[row][col])
                    );                     
                end
                else if (col == num_col) begin                // PE placed in first col, left data from row_in
                    PE #(.in_DW(data_width)) PE_unit(
                        .clk(clk), 
                        .rst_n(rst_n),
                        .en(en), 
                        .clc(clc[row][col]),
                        .in_left(row_in[row]), 
                        .in_up(shift_down[row+1][col]), 
                        .out_right(shift_right[row][col]), 
                        .out_down(shift_down[row][col]), 
                        .result(sum[row][col])
                    );
                end
                else begin
                    PE #(.in_DW(data_width)) PE_unit(
                        .clk(clk), 
                        .rst_n(rst_n),
                        .en(en), 
                        .clc(clc[row][col]),
                        .in_left(shift_right[row][col+1]), 
                        .in_up(shift_down[row+1][col]), 
                        .out_right(shift_right[row][col]), 
                        .out_down(shift_down[row][col]), 
                        .result(sum[row][col])
                    );
                end
            end
        end
    endgenerate

integer i,j;

always @(posedge clk) begin
    if(~rst_n) begin
        foreach(sum_R[m,n])
            sum_R[m][n] <= '0; 
    end
    else begin
        for(i=num_row; i>0; i=i-1) begin
            for(j=num_col; j>0; j=j-1) begin
                if (clc[i][j] == 1) begin
                    sum_R[i][j] <= sum[i][j];
                end
                else begin
                    sum_R[i][j] <= sum_R[i][j];
                end
            end
        end
    end
end

always @(*) begin
        if (row_out_valid == 0) begin
            row_out = '{(num_col-1){0}};
        end
        else begin
            for (i=num_row; i>0; i=i-1) begin
                if(row_out_valid[i] == 1) begin
                    row_out = sum_R[i];
                end
            end
        end
end

// assign row_out = (row_out_valid[16] == 1) ? (sum_R[16]) : 
//                  (row_out_valid[15] == 1) ? (sum_R[15]) : 
//                  (row_out_valid[14] == 1) ? (sum_R[14]) : 
//                  (row_out_valid[13] == 1) ? (sum_R[13]) : 
//                  (row_out_valid[12] == 1) ? (sum_R[12]) : 
//                  (row_out_valid[11] == 1) ? (sum_R[11]) : 
//                  (row_out_valid[10] == 1) ? (sum_R[10]) : 
//                  (row_out_valid[9]  == 1) ? (sum_R[9] ) : 
//                  (row_out_valid[8]  == 1) ? (sum_R[8] ) : 
//                  (row_out_valid[7]  == 1) ? (sum_R[7] ) : 
//                  (row_out_valid[6]  == 1) ? (sum_R[6] ) : 
//                  (row_out_valid[5]  == 1) ? (sum_R[5] ) : 
//                  (row_out_valid[4]  == 1) ? (sum_R[4] ) : 
//                  (row_out_valid[3]  == 1) ? (sum_R[3] ) : 
//                  (row_out_valid[2]  == 1) ? (sum_R[2] ) : 
//                  (row_out_valid[1]  == 1) ? (sum_R[1] ) : 
//                  ('{(num_col-1){0}});


endmodule
