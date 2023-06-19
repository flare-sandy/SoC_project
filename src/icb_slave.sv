`define STAT_REG_ADDR           12'h00
`define CONFIG_REG_ADDR         12'h04
`define BASERDADDR_REG_ADDR     12'h08
`define BASEWRADDR_REG_ADDR     12'h12


module icb_slave(
    // icb bus
    input               icb_cmd_valid,
    output  reg         icb_cmd_ready,
    input               icb_cmd_read,
    input       [31:0]  icb_cmd_addr,
    input       [31:0]  icb_cmd_wdata,
    input       [3:0]   icb_cmd_wmask,

    output  reg         icb_rsp_valid,
    input               icb_rsp_ready,
    output  reg [31:0]  icb_rsp_rdata,
    output              icb_rsp_err,

    // clk & rst_n
    input           clk,
    input           rst_n,

    // reg IO
    output  reg [15:0]  STAT_REG_WR,
    output  reg [31:0]  CONFIG_REG,
    output  reg [31:0]  BASERDADDR_REG,
    
    input       [15:0]  STAT_REG_RD

);

assign icb_rsp_err = 1'b0;

// cmd ready, icb_cmd_ready
always@(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        icb_cmd_ready <= 1'b0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready) begin
            icb_cmd_ready <= 1'b0;
        end
        else if(icb_cmd_valid) begin
            icb_cmd_ready <= 1'b1;
        end
        else begin
            icb_cmd_ready <= icb_cmd_ready;
        end
    end
end

// ADDR and PARAM setting
always@(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        STAT_REG_WR <= 32'h0;
        CONFIG_REG <= 32'h0;
        BASERDADDR_REG <= 32'h0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready & !icb_cmd_read) begin
            case(icb_cmd_addr[11:0])
                `STAT_REG_ADDR:     STAT_REG_WR <= icb_cmd_wdata;
                `CONFIG_REG_ADDR:   CONFIG_REG <= icb_cmd_wdata;
                `BASERDADDR_REG_ADDR: BASERDADDR_REG <= icb_cmd_wdata;
            endcase
        end
        else begin
            STAT_REG_WR <= 0;
        end
    end
end

// response valid, icb_rsp_valid
always@(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        icb_rsp_valid <= 1'h0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready) begin
            icb_rsp_valid <= 1'h1;
        end
        else if(icb_rsp_valid & icb_rsp_ready) begin
            icb_rsp_valid <= 1'h0;
        end
        else begin
            icb_rsp_valid <= icb_rsp_valid;
        end
    end
end

// read data, icb_rsp_rdata
always@(negedge rst_n or posedge clk) begin
    if(!rst_n) begin
        icb_rsp_rdata <= 32'h0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready & icb_cmd_read) begin
            case(icb_cmd_addr[11:0])
                `STAT_REG_ADDR:  icb_rsp_rdata <= {STAT_REG_RD, {16'd0}};
                `CONFIG_REG_ADDR:  icb_rsp_rdata <= CONFIG_REG;
                `BASERDADDR_REG_ADDR  :  icb_rsp_rdata <= BASERDADDR_REG;
            endcase
        end
        else begin
            icb_rsp_rdata <= 32'h0;
        end
    end
end

endmodule
