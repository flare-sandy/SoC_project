module SA_control #(  // control logic for 8x8 SA
    parameter depth = 64
)
(
    input logic clk,
    input logic rst_n,
    input logic en,

    // from in_buffer
    input logic [depth-1:0] start_addr_in_buffer,
    input logic [depth-1:0] len_in_buffer,
    // to in_buffer
    output logic rd_in_buffer,
    output logic [depth-1:0] rd_addr_in_buffer,

    // to SA
    output logic en_SA,
    output logic [8:1][8:1] clc_SA,
    output logic [8:1] row_out_valid,
    output logic FLAG_finish,

    // from out_buffer
    input logic [depth-1:0] start_addr_out_buffer,
    // to out_buffer
    output logic wr_out_buffer,
    output logic [depth-1:0] wr_addr_out_buffer
);

localparam IDLE      = 3'd0;
localparam DATAIN    = 3'd1; // data from in_buffer to SA
localparam DATAOUT   = 3'd2;  // data from SA to out_buffer
localparam FINISH    = 3'd3;  // finish calculation

reg [5:0] state;
reg [3:0] out_counter;

always_ff @(posedge clk) begin
    if(!rst_n) begin
        state <= IDLE;
        out_counter <= 0;
        // to in_buffer
        rd_in_buffer <= 1'b0;
        rd_addr_in_buffer <= {depth{1'b0}};
        // to SA
        en_SA <= 1'b0;
        clc_SA <= 64'b0;
        row_out_valid <= 8'b0000_0000;
        FLAG_finish <= 1'b0;
        // to out_buffer
        wr_out_buffer <= 1'b0;
        wr_addr_out_buffer <= {depth{1'b0}};
    end
    else if(en) begin
        case (state)
            IDLE: begin
                state <= DATAIN;
                out_counter <= 0;
                // to in_buffer
                rd_in_buffer <= 1'b1;
                rd_addr_in_buffer <= start_addr_in_buffer;
                // to SA
                en_SA <= 1'b1;
                clc_SA <= 64'b0;
                row_out_valid <= 8'b0000_0000;
                FLAG_finish <= 1'b0;
                // to out_buffer
                wr_out_buffer <= 1'b0;
                wr_addr_out_buffer <= {depth{1'b0}};
            end

            DATAIN: begin //load data from in_buffer to SA, get the first result in SA after 96 cycles
                if (rd_addr_in_buffer == start_addr_in_buffer + len_in_buffer) begin
                    state <= DATAOUT;
                    // to in_buffer
                    rd_in_buffer <= 1'b0;
                    rd_addr_in_buffer <= {depth{1'b0}};
                end
                else begin 
                    state <= DATAIN;
                    // to in_buffer
                    rd_in_buffer <= 1'b1;
                    rd_addr_in_buffer <= rd_addr_in_buffer + 1'b1;
                end
                out_counter <= 0;
                // to SA
                en_SA <= 1'b1;
                clc_SA <= 64'b0;
                row_out_valid <= 8'b0000_0000;
                FLAG_finish <= 1'b0;
                // to out_buffer
                wr_out_buffer <= 1'b0;
                wr_addr_out_buffer <= {depth{1'b0}};
            end

            DATAOUT: begin  //output results from SA to out_buffer
                out_counter <= out_counter + 1'b1;
                // to in_buffer
                rd_in_buffer <= 1'b0;
                rd_addr_in_buffer <= {depth{1'b0}};
                // to SA
                en_SA <= 1'b1;
                FLAG_finish <= 1'b0;

                case (out_counter)
                    4'b0000: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {{1'b1}, {63{1'b0}}};
                        row_out_valid <= 8'b0000_0000;
                        // to out_buffer
                        wr_out_buffer <= 1'b0;
                        wr_addr_out_buffer <= {depth{1'b0}};
                    end
                    4'b0001: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {{1'b0}, {1'b1}, {6{1'b0}}, {1'b1}, {55{1'b0}}};
                        row_out_valid <= 8'b0000_0000;
                        // to out_buffer
                        wr_out_buffer <= 1'b0;
                        wr_addr_out_buffer <= {depth{1'b0}};
                    end
                    4'b0010: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {{2{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {47{1'b0}}};
                        row_out_valid <= 8'b0000_0000;
                        // to out_buffer
                        wr_out_buffer <= 1'b0;
                        wr_addr_out_buffer <= {depth{1'b0}};
                    end
                    4'b0011: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {{3{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {39{1'b0}}};
                        row_out_valid <= 8'b0000_0000;
                        // to out_buffer
                        wr_out_buffer <= 1'b0;
                        wr_addr_out_buffer <= {depth{1'b0}};
                    end
                    4'b0100: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {{4{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {31{1'b0}}};
                        row_out_valid <= 8'b0000_0000;
                        // to out_buffer
                        wr_out_buffer <= 1'b0;
                        wr_addr_out_buffer <= {depth{1'b0}};
                    end
                    4'b0101: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {{5{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {23{1'b0}}};
                        row_out_valid <= 8'b0000_0000;
                        // to out_buffer
                        wr_out_buffer <= 1'b0;
                        wr_addr_out_buffer <= {depth{1'b0}};
                    end                    
                    4'b0110: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {{6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {15{1'b0}}};
                        row_out_valid <= 8'b0000_0000;
                        // to out_buffer
                        wr_out_buffer <= 1'b0;
                        wr_addr_out_buffer <= {depth{1'b0}};
                    end  
                    4'b0111: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {{7{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {7{1'b0}}};
                        row_out_valid <= 8'b1000_0000;
                        // to out_buffer
                        wr_out_buffer <= 1'b1;
                        wr_addr_out_buffer <= start_addr_out_buffer;
                    end  
                    4'b1000: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {{15{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}};
                        row_out_valid <= 8'b0100_0000;
                        // to out_buffer
                        wr_out_buffer <= 1'b1;
                        wr_addr_out_buffer <= wr_addr_out_buffer + 1'b1;
                    end  
                    4'b1001: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {{23{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {5{1'b0}}};
                        row_out_valid <= 8'b0010_0000;
                        // to out_buffer
                        wr_out_buffer <= 1'b1;
                        wr_addr_out_buffer <= wr_addr_out_buffer + 1'b1;
                    end  
                    4'b1010: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {{31{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {4{1'b0}}};
                        row_out_valid <= 8'b0001_0000;
                        // to out_buffer
                        wr_out_buffer <= 1'b1;
                        wr_addr_out_buffer <= wr_addr_out_buffer + 1'b1;
                    end
                    4'b1011: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {{39{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {3{1'b0}}};
                        row_out_valid <= 8'b0000_1000;
                        // to out_buffer
                        wr_out_buffer <= 1'b1;
                        wr_addr_out_buffer <= wr_addr_out_buffer + 1'b1;
                    end  
                    4'b1100: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {{47{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {2{1'b0}}};
                        row_out_valid <= 8'b0000_0100;
                        // to out_buffer
                        wr_out_buffer <= 1'b1;
                        wr_addr_out_buffer <= wr_addr_out_buffer + 1'b1;
                    end  
                    4'b1101: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {{55{1'b0}}, {1'b1}, {6{1'b0}}, {1'b1}, {1'b0}};
                        row_out_valid <= 8'b0000_0010;
                        // to out_buffer
                        wr_out_buffer <= 1'b1;
                        wr_addr_out_buffer <= wr_addr_out_buffer + 1'b1;
                    end  
                    4'b1110: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {{63{1'b0}}, {1'b1}};
                        row_out_valid <= 8'b0000_0001;
                        // to out_buffer
                        wr_out_buffer <= 1'b1;
                        wr_addr_out_buffer <= wr_addr_out_buffer + 1'b1;
                    end  
                    4'b1111: begin
                        state <= FINISH;
                        // to SA
                        clc_SA <= {64{1'b0}};
                        row_out_valid <= 8'b0000_0000;
                        // to out_buffer
                        wr_out_buffer <= 1'b0;
                        wr_addr_out_buffer <= {depth{1'b0}};
                    end  
                    default: begin
                        state <= DATAOUT;
                        // to SA
                        clc_SA <= {64{1'b0}};
                        row_out_valid <= 8'b0000_0000;
                        // to out_buffer
                        wr_out_buffer <= 1'b0;
                        wr_addr_out_buffer <= {depth{1'b0}};
                    end
                endcase
            end

            FINISH: begin
                state <= IDLE;
                out_counter <= 0;
                // to in_buffer
                rd_in_buffer <= 1'b1;
                rd_addr_in_buffer <= {depth{1'b0}};
                // to SA
                en_SA <= 1'b1;
                clc_SA <= 64'b0;
                row_out_valid <= 8'b0;
                FLAG_finish <= 1'b1;
                // to out_buffer
                wr_out_buffer <= 1'b0;
                wr_addr_out_buffer <= {depth{1'b0}};
            end

            default: begin
                state <= DATAIN;
                out_counter <= 0;
                // to in_buffer
                rd_in_buffer <= 1'b1;
                rd_addr_in_buffer <= start_addr_in_buffer;
                // to SA
                en_SA <= 1'b1;
                clc_SA <= 64'b0;
                FLAG_finish <= 1'b0;
                // to out_buffer
                wr_out_buffer <= 1'b0;
                wr_addr_out_buffer <= {depth{1'b0}};
            end
        endcase

    end
end

// always @(posedge clk) begin
//     if(!rst_n) begin
//         rd_out_buffer <= 1'b0;
//         r_addr_out_buffer <= 4'b0;
//     end 
//     else if(FLAG_finish) begin
//         rd_out_buffer <= 1'b1;
//         r_addr_out_buffer <= 4'b1000;
//     end
//     else if(r_addr_out_buffer > 4'b0001) begin
//         rd_out_buffer <= 1'b1;
//         r_addr_out_buffer <= r_addr_out_buffer - 1'b1;
//     end
//     else begin
//         rd_out_buffer <= 1'b0;
//         r_addr_out_buffer <= 4'b0;
//     end
// end

endmodule