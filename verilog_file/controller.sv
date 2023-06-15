module control (
    input clk,
    input rst_n,
    input en,
    // from BRAM
    input [7:0] start_addr,
    input [7:0] end_addr,
    // to BRAM
    output reg en_BRAM,
    output reg wea_BRAM,
    output reg [7:0] addr_BRAM,
    // to in_buffer
    output reg en_in_buffer,
    output reg wr_in_buffer,
    output reg rd_in_buffer,
    output reg [3:0] w_addr_in_buffer,
    output reg [3:0] r_addr_in_buffer,
    // to PE_array
    output reg en_PE,
    output reg [8*8-1:0] clc_PE,
    // to out_buffer
    output reg en_out_buffer,
    output reg wr_out_buffer,
    output reg rd_out_buffer,
    output reg matrix_out,
    output reg [3:0] w_addr_out_buffer,
    output reg [3:0] r_addr_out_buffer,
    output reg [7:0] row_valid // each row
);

parameter IDLE = 6'd0;
parameter DATAIN = 6'd1; // data from BRAM to in_buffer, 8T
parameter PECAL = 6'd2;  // data from in_buffer to PE, calculate mul and acc
parameter DATAOUT = 6'd3;  // data from PE to out_buffer, 15T
parameter MATRIXOUT = 6'd4;  // data from out_buffer to BRAM
parameter FINISH = 6'd5;  // finish calculation

reg [5:0] state;
reg [6:0] cal_counter;
reg [3:0] out_counter;

always @(posedge clk) begin
    if(!rst_n) begin
        state <= IDLE;
        // to BRAM
        en_BRAM <= 1'b0;
        wea_BRAM <= 1'b0;
        addr_BRAM <= 8'b0;
        // to in_buffer
        en_in_buffer <= 1'b0;
        wr_in_buffer <= 1'b0;
        rd_in_buffer <= 1'b0;
        w_addr_in_buffer <= 4'b0;
        r_addr_in_buffer <= 4'b0;
        // to PE_array
        en_PE <= 1'b0;
        clc_PE <= 64'b0;
        // to out_buffer
        en_out_buffer <= 1'b0;
        wr_out_buffer <= 1'b0;
        // rd_out_buffer <= 1'b0;
        matrix_out <= 1'b0;
        w_addr_out_buffer <= 4'b0;
        // r_addr_out_buffer <= 4'b0;
        row_valid <= 8'b0;
    end
    else if(en) begin
        case (state)
            IDLE: begin
                if(addr_BRAM <= end_addr) begin
                    state <= DATAIN;
                    // to BRAM
                    en_BRAM <= 1'b1;
                    wea_BRAM <= 1'b0;
                    matrix_out <= 1'b0;
                    addr_BRAM <= start_addr;
                    // to in_buffer
                    en_in_buffer <= 1'b1;
                    wr_in_buffer <= 1'b1;
                    w_addr_in_buffer <= 4'b0;
                    // to out_buffer
                    // en_out_buffer <= 1'b0;
                end
                else begin
                    state <= IDLE;
                    // to BRAM
                    en_BRAM <= 1'b0;
                    wea_BRAM <= 1'b0;
                    matrix_out <= 1'b0;
                    addr_BRAM <= end_addr + 1;
                    // to in_buffer
                    en_in_buffer <= 1'b0;
                    wr_in_buffer <= 1'b0;
                    w_addr_in_buffer <= 4'b0;
                    // to out_buffer
                    // en_out_buffer <= 1'b0;
                end
            end

            DATAIN: begin //read data from BRAM to in_buffer, requires at least 8 clock
                addr_BRAM <= addr_BRAM + 1'b1;
                if(addr_BRAM == start_addr) begin
                    w_addr_in_buffer <= 4'b0;
                end
                else begin
                    w_addr_in_buffer <= w_addr_in_buffer + 1'b1;
                end
                if(addr_BRAM == start_addr + 8) begin
                    state <= PECAL;
                    rd_in_buffer <= 1'b1;
                    r_addr_in_buffer <= 4'b0;
                    en_PE <= 1'b1;
                    cal_counter <= 7'b0;
                end
                else begin
                    state <= DATAIN;
                    rd_in_buffer <= 1'b0;
                    r_addr_in_buffer <= 4'b0;
                    en_PE <= 1'b0;
                    cal_counter <= 7'b0;
                end
            end

            PECAL: begin  //read data from in_buffer to PE to calculat, and continues to read data from BRAM to in_buffer
                matrix_out <= 1'b0;
                // en_out_buffer <= 1'b0;

                // BRAM to in_buffer
                if(addr_BRAM <= end_addr) begin
                    addr_BRAM <= addr_BRAM + 1'b1;
                    wr_in_buffer <= 1'b1;
                    w_addr_in_buffer <= w_addr_in_buffer + 1'b1;
                end
                else begin  // finish BRAM read and in_buffer write
                    addr_BRAM <= end_addr+1;
                    wr_in_buffer <= 1'b0;
                    w_addr_in_buffer <= w_addr_in_buffer;
                end

                // read data from in_buffer to PE
                r_addr_in_buffer <= r_addr_in_buffer + 1'b1;
                cal_counter <= cal_counter + 1'b1;
                if (cal_counter == 63) begin  //the first PE finish current calculation
                    state <= DATAOUT;
                    wr_out_buffer <= 1'b1;
                    w_addr_out_buffer <= 4'b0000;
                    out_counter <= 5'b0;
                end
                else begin
                    state <= PECAL;
                    wr_out_buffer <= 1'b0;
                    w_addr_out_buffer <= 4'b0000;
                    out_counter <= 5'b0;
                end
            end

            DATAOUT: begin  //output results from PE to out_buffer, and continue to read data as in PECAL
                // BRAM to in_buffer
                cal_counter <= 7'b0;
                if(addr_BRAM <= end_addr) begin
                    addr_BRAM <= addr_BRAM + 1'b1;
                    w_addr_in_buffer <= w_addr_in_buffer + 1'b1;
                end
                else begin  // finish BRAM read
                    addr_BRAM <= end_addr + 1;
                    w_addr_in_buffer <= w_addr_in_buffer;
                end

                // read data from in_buffer to PE
                if(addr_BRAM == (end_addr + 1) && out_counter >= 6) begin // finish data read
                    r_addr_in_buffer <= r_addr_in_buffer;
                    rd_in_buffer <= 1'b0;
                    en_in_buffer <= 1'b0;
                end
                else begin
                    r_addr_in_buffer <= r_addr_in_buffer + 1'b1;
                    rd_in_buffer <= 1'b1;
                    en_in_buffer <= 1'b1;
                end

                // if(out_counter == 4'b1111) begin
                //     state <= MATRIXOUT;
                // end
                out_counter <= out_counter + 1'b1;
                // output one row per 2T clock
                case (out_counter)
                    4'b0000: begin
                        clc_PE[63] <= 1'b1;

                        en_out_buffer <= 1'b0;
                        row_valid  <= 8'b1000_0000;
                        w_addr_out_buffer <= 4'b1000;
                    end
                    4'b0001: begin
                        clc_PE[63] <= 1'b0;
                        
                        clc_PE[55] <= 1'b1;

                        en_out_buffer <= 1'b1;
                    end
                    4'b0010: begin
                        clc_PE[55] <= 1'b0;

                        clc_PE[54] <= 1'b1;
                        clc_PE[47] <= 1'b1;

                        en_out_buffer <= 1'b0;
                        row_valid  <= 8'b1100_0000;
                        w_addr_out_buffer <= 4'b0111;
                    end
                    4'b0011: begin
                        clc_PE[54] <= 1'b0;
                        clc_PE[47] <= 1'b0;

                        clc_PE[46] <= 1'b1;
                        clc_PE[39] <= 1'b1;

                        en_out_buffer <= 1'b1;
                    end
                    4'b0100: begin
                        clc_PE[46] <= 1'b0;
                        clc_PE[39] <= 1'b0;

                        clc_PE[45] <= 1'b1;
                        clc_PE[38] <= 1'b1;
                        clc_PE[31] <= 1'b1;

                        en_out_buffer <= 1'b0;
                        row_valid  <= 8'b1110_0000;
                        w_addr_out_buffer <= 4'b0110;
                    end
                    4'b0101: begin
                        clc_PE[45] <= 1'b0;
                        clc_PE[38] <= 1'b0;
                        clc_PE[31] <= 1'b0;

                        clc_PE[37] <= 1'b1;
                        clc_PE[30] <= 1'b1;
                        clc_PE[23] <= 1'b1;
                        
                        en_out_buffer <= 1'b1;
                    end                    
                    4'b0110: begin
                        clc_PE[37] <= 1'b0;
                        clc_PE[30] <= 1'b0;
                        clc_PE[23] <= 1'b0;

                        clc_PE[36] <= 1'b1;
                        clc_PE[29] <= 1'b1;
                        clc_PE[22] <= 1'b1;
                        clc_PE[15] <= 1'b1;

                        en_out_buffer <= 1'b0;
                        row_valid  <= 8'b1111_0000;
                        w_addr_out_buffer <= 4'b0101;
                    end  

                    4'b0111: begin
                        clc_PE[36] <= 1'b0;
                        clc_PE[29] <= 1'b0;
                        clc_PE[22] <= 1'b0;
                        clc_PE[15] <= 1'b0;

                        clc_PE[28] <= 1'b1;
                        clc_PE[21] <= 1'b1;
                        clc_PE[14] <= 1'b1;
                        clc_PE[7]  <= 1'b1;
                        
                        en_out_buffer <= 1'b1;
                    end  
                    4'b1000: begin
                        clc_PE[28] <= 1'b0;
                        clc_PE[21] <= 1'b0;
                        clc_PE[14] <= 1'b0;
                        clc_PE[7]  <= 1'b0;

                        clc_PE[27] <= 1'b1;
                        clc_PE[20] <= 1'b1;
                        clc_PE[13] <= 1'b1;
                        clc_PE[6]  <= 1'b1;

                        en_out_buffer <= 1'b0;
                        row_valid  <= 8'b1111_1000;
                        w_addr_out_buffer <= 4'b0100;
                    end  
                    4'b1001: begin
                        clc_PE[27] <= 1'b0;
                        clc_PE[20] <= 1'b0;
                        clc_PE[13] <= 1'b0;
                        clc_PE[6]  <= 1'b0;

                        clc_PE[19] <= 1'b1;
                        clc_PE[12] <= 1'b1;
                        clc_PE[5]  <= 1'b1;
                        
                        en_out_buffer <= 1'b1;
                    end  
                    4'b1010: begin
                        clc_PE[19] <= 1'b0;
                        clc_PE[12] <= 1'b0;
                        clc_PE[5]  <= 1'b0;

                        clc_PE[18] <= 1'b1;
                        clc_PE[11] <= 1'b1;
                        clc_PE[4]  <= 1'b1;

                        en_out_buffer <= 1'b0;
                        row_valid  <= 8'b1111_1100;
                        w_addr_out_buffer <= 4'b0011;
                    end
                    4'b1011: begin
                        clc_PE[18] <= 1'b0;
                        clc_PE[11] <= 1'b0;
                        clc_PE[4]  <= 1'b0;

                        clc_PE[10] <= 1'b1;
                        clc_PE[3]  <= 1'b1;
                        
                        en_out_buffer <= 1'b1;
                    end  
                    4'b1100: begin
                        clc_PE[10] <= 1'b0;
                        clc_PE[3]  <= 1'b0;

                        clc_PE[9]  <= 1'b1;
                        clc_PE[2]  <= 1'b1;

                        en_out_buffer <= 1'b0;
                        row_valid  <= 8'b1111_1110;
                        w_addr_out_buffer <= 4'b0010;
                    end  
                    4'b1101: begin
                        clc_PE[9]  <= 1'b0;
                        clc_PE[2]  <= 1'b0;

                        clc_PE[1]  <= 1'b1;
                        
                        en_out_buffer <= 1'b1;
                    end  
                    4'b1110: begin
                        clc_PE[1]  <= 1'b0;

                        clc_PE[0]  <= 1'b1;

                        en_out_buffer <= 1'b0;
                        row_valid  <= 8'b1111_1111;
                        w_addr_out_buffer <= 4'b0001;
                    end  
                    4'b1111: begin
                        clc_PE[0]  <= 1'b0;
                        // row_valid  <= 8'b0000_0000;
                        // w_addr_out_buffer <= 4'b0000;
                        en_out_buffer <= 1'b1;
                        state <= MATRIXOUT;
                    end  
                    default: begin
                        clc_PE <= 64'b0;
                        en_out_buffer <= 1'b0;
                        row_valid  <= 8'b0000_0000;
                        w_addr_out_buffer <= 4'b0000;
                    end
                endcase
            end

            MATRIXOUT: begin
                en_out_buffer <= 1'b1;
                wr_out_buffer <= 1'b0;
                row_valid  <= 8'b0000_0000;
                w_addr_out_buffer <= 4'b0000;
                if(addr_BRAM <= end_addr) begin
                    state <= PECAL;
                end
                else begin
                    state <= IDLE;
                end
                matrix_out <= 1'b1;
                // r_addr_out_buffer <= 4'b1000;
            end

            default: begin
                state <= IDLE;
                // to BRAM
                en_BRAM <= 1'b0;
                wea_BRAM <= 1'b0;
                addr_BRAM <= 8'b0;
                // to in_buffer
                en_in_buffer <= 1'b0;
                wr_in_buffer <= 1'b0;
                rd_in_buffer <= 1'b0;
                w_addr_in_buffer <= 4'b0;
                r_addr_in_buffer <= 4'b0;
                // to PE_array
                en_PE <= 1'b0;
                clc_PE <= 64'b0;
                // to out_buffer
                en_out_buffer <= 1'b0;
                wr_out_buffer <= 1'b0;
                // rd_out_buffer <= 1'b0;
                matrix_out <= 1'b0;
                w_addr_out_buffer <= 4'b0;
                // r_addr_out_buffer <= 4'b0;
                row_valid <= 8'b0;
            end
        endcase

    end
end

always @(posedge clk) begin
    if(!rst_n) begin
        rd_out_buffer <= 1'b0;
        r_addr_out_buffer <= 4'b0;
    end 
    else if(matrix_out) begin
        rd_out_buffer <= 1'b1;
        r_addr_out_buffer <= 4'b1000;
    end
    else if(r_addr_out_buffer > 4'b0001) begin
        rd_out_buffer <= 1'b1;
        r_addr_out_buffer <= r_addr_out_buffer - 1'b1;
    end
    else begin
        rd_out_buffer <= 1'b0;
        r_addr_out_buffer <= 4'b0;
    end
end

endmodule