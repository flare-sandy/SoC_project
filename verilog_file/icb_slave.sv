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
<<<<<<< HEAD
always@(negedge rst_n or posedge clk) begin
=======
always@(posedge clk)
begin
>>>>>>> 306e261c69f81c819fef99514e4d0dd9537f1b24
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

<<<<<<< HEAD
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
=======
logic [11:0] offset;
assign offset = icb_cmd_addr[11:0];

// config
always_ff @(posedge clk)
begin
    if(!rst_n) begin
        CONTROL <= 32'b0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready & !icb_cmd_read) begin
            case(offset)
                `CONTROL_ADDR:  CONTROL <= icb_cmd_wdata;
            endcase
        end
        else begin
            CONTROL <= CONTROL;
>>>>>>> 306e261c69f81c819fef99514e4d0dd9537f1b24
        end
    end
end

<<<<<<< HEAD
// response valid, icb_rsp_valid
always@(negedge rst_n or posedge clk) begin
=======
logic [63:0] wdata_sram;
logic wdata_valid;


// wdata_sram setting
always_ff @(posedge clk)
begin
    if(!rst_n) begin
        wdata_sram <= 64'b0;
        wdata_valid <= 1'b0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready & !icb_cmd_read & (offset >= `INPUT_ADDR) & (offset < `CONTROL_ADDR)) begin
            wdata_sram <= wdata_valid ? {icb_cmd_wdata, wdata_sram[31:0]} : {{32'b0}, icb_cmd_wdata};
            wdata_valid <= ~wdata_valid;
        end
        else begin
            wdata_sram <= wdata_sram;
            wdata_valid <= wdata_valid;
        end
    end
end

assign wdata_sram_input = wdata_sram;
assign wdata_sram_wq0   = wdata_sram;
assign wdata_sram_wq1   = wdata_sram;
assign wdata_sram_wk0   = wdata_sram;
assign wdata_sram_wk1   = wdata_sram;
assign wdata_sram_wv0   = wdata_sram;
assign wdata_sram_wv1   = wdata_sram;


// wsbn_sram and waddr_sram
always_ff @(posedge clk)
begin
    if(!rst_n) begin
        {wsbn_sram_input, wsbn_sram_wq0, wsbn_sram_wq1, wsbn_sram_wk0, wsbn_sram_wk1, wsbn_sram_wv0, wsbn_sram_wv1} <= 7'b111_1111;
        {waddr_sram_input, waddr_sram_wq0, waddr_sram_wq1, waddr_sram_wk0, waddr_sram_wk1, waddr_sram_wv0, waddr_sram_wv1} <= 84'b0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready & !icb_cmd_read & (offset >= `INPUT_ADDR) & (offset < `CONTROL_ADDR)) begin
            if (offset < `WQ0_ADDR) begin
                wsbn_sram_input <= wdata_valid ? 1'b0 : 1'b1;
                waddr_sram_input <= offset - `INPUT_ADDR;
            end
            else if(offset < `WQ1_ADDR) begin
                wsbn_sram_wq0   <= wdata_valid ? 1'b0 : 1'b1;
                waddr_sram_wq0  <= offset - `WQ0_ADDR;
            end
            else if(offset < `WK0_ADDR) begin
                wsbn_sram_wq1   <= wdata_valid ? 1'b0 : 1'b1;
                waddr_sram_wq1  <= offset - `WQ1_ADDR;
            end
            else if(offset < `WK1_ADDR) begin
                wsbn_sram_wk0   <= wdata_valid ? 1'b0 : 1'b1;
                waddr_sram_wk0  <= offset - `WK0_ADDR;
            end
            else if(offset < `WV0_ADDR) begin
                wsbn_sram_wk1   <= wdata_valid ? 1'b0 : 1'b1;
                waddr_sram_wk1  <= offset - `WK1_ADDR;
            end
            else if(offset < `WV1_ADDR) begin
                wsbn_sram_wv0   <= wdata_valid ? 1'b0 : 1'b1;
                waddr_sram_wv0  <= offset - `WV0_ADDR;
            end
            else if(offset < `CONTROL_ADDR) begin
                wsbn_sram_wv1   <= wdata_valid ? 1'b0 : 1'b1;
                waddr_sram_wv1  <= offset - `WV1_ADDR;
            end
        end
        else begin
            {wsbn_sram_input, wsbn_sram_wq0, wsbn_sram_wq1, wsbn_sram_wk0, wsbn_sram_wk1, wsbn_sram_wv0, wsbn_sram_wv1} <= {wsbn_sram_input, wsbn_sram_wq0, wsbn_sram_wq1, wsbn_sram_wk0, wsbn_sram_wk1, wsbn_sram_wv0, wsbn_sram_wv1};
            {waddr_sram_input, waddr_sram_wq0, waddr_sram_wq1, waddr_sram_wk0, waddr_sram_wk1, waddr_sram_wv0, waddr_sram_wv1} <= {waddr_sram_input, waddr_sram_wq0, waddr_sram_wq1, waddr_sram_wk0, waddr_sram_wk1, waddr_sram_wv0, waddr_sram_wv1};
        end
    end
end


// response valid, icb_rsp_valid
always_ff @(posedge clk)
begin
>>>>>>> 306e261c69f81c819fef99514e4d0dd9537f1b24
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
<<<<<<< HEAD
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
=======
logic rdata_valid;

assign csbn_sram_output  = (icb_cmd_valid & icb_cmd_ready & icb_cmd_read & (offset < `WQ0_ADDR)) ? 1'b0 : 1'b1;
assign raddr_sram_output = (icb_cmd_valid & icb_cmd_ready & icb_cmd_read & (offset < `WQ0_ADDR)) ? offset : 12'b0;

always_ff @(posedge clk)
begin
    if(!rst_n) begin
        icb_rsp_rdata <= 32'h0;
        rdata_valid   <= 1'h0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready & icb_cmd_read & (offset >= `CONTROL_ADDR)) begin
            case(icb_cmd_addr[11:0])
                `CONTROL_ADDR:  icb_rsp_rdata   <= CONTROL;
                `STATUS_ADDR:   icb_rsp_rdata   <= STATUS;
            endcase
        end
        else if (icb_cmd_valid & icb_cmd_ready & icb_cmd_read & (offset >= `INPUT_ADDR) & (offset < `WQ0_ADDR)) begin
            icb_rsp_rdata <= rdata_valid ? rdata_sram_output[63:32] : rdata_sram_output[31:0];
            rdata_valid   <= ~rdata_valid;
        end  
        else begin
            icb_rsp_rdata <= 32'h0;
            rdata_valid   <= rdata_valid;
>>>>>>> 306e261c69f81c819fef99514e4d0dd9537f1b24
        end
    end
end

<<<<<<< HEAD
endmodule
=======
endmodule
>>>>>>> 306e261c69f81c819fef99514e4d0dd9537f1b24
