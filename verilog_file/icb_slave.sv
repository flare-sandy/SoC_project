
`define INPUT_ADDR     12'h000  // 32*96/8=384
`define WQ0_ADDR       12'h180  // 96*48/8=576，384+576=960
`define WQ1_ADDR       12'h3C0  // 96*48/8=576，960+576=1536
`define WK0_ADDR       12'h600  // 96*48/8=576，1536+576=2112
`define WK1_ADDR       12'h840  // 96*48/8=576，2112+576=2688
`define WV0_ADDR       12'hA80  // 96*48/8=576，2688+576=3264
`define WV1_ADDR       12'hCC0  // 96*48/8=576，3264+576=3840(0xF00)
`define CONTROL_ADDR   12'hF00
`define STATUS_ADDR    12'hF04


module icb_slave(
    // clk & rst_n
    input  logic             clk,
    input  logic             rst_n,

    // icb bus
    input  logic             icb_cmd_valid,
    output logic             icb_cmd_ready,
    input  logic             icb_cmd_read,
    input  logic     [31:0]  icb_cmd_addr,
    input  logic     [31:0]  icb_cmd_wdata,
    input  logic     [3:0]   icb_cmd_wmask,

    output logic             icb_rsp_valid,
    input  logic             icb_rsp_ready,
    output logic     [31:0]  icb_rsp_rdata,
    output logic             icb_rsp_err,

    // reg output
    output  logic            wsbn_sram_input,
    output  logic            csbn_sram_input,
    output  logic    [11:0]  waddr_sram_input,
    output  logic    [63:0]  wdata_sram_input,

    output  logic            wsbn_sram_wq0,
    output  logic            csbn_sram_wq0,
    output  logic    [11:0]  waddr_sram_wq0,
    output  logic    [63:0]  wdata_sram_wq0,

    output  logic            wsbn_sram_wq1,
    output  logic            csbn_sram_wq1,
    output  logic    [11:0]  waddr_sram_wq1,
    output  logic    [63:0]  wdata_sram_wq1,

    output  logic            wsbn_sram_wk0,
    output  logic            csbn_sram_wk0,
    output  logic    [11:0]  waddr_sram_wk0,
    output  logic    [63:0]  wdata_sram_wk0,

    output  logic            wsbn_sram_wk1,
    output  logic            csbn_sram_wk1,
    output  logic    [11:0]  waddr_sram_wk1,
    output  logic    [63:0]  wdata_sram_wk1,

    output  logic            wsbn_sram_wv0,
    output  logic            csbn_sram_wv0,
    output  logic    [11:0]  waddr_sram_wv0,
    output  logic    [63:0]  wdata_sram_wv0,

    output  logic            wsbn_sram_wv1,
    output  logic            csbn_sram_wv1,
    output  logic    [11:0]  waddr_sram_wv1,
    output  logic    [63:0]  wdata_sram_wv1,

    output  logic            csbn_sram_output,
    output  logic    [11:0]  raddr_sram_output,
    input   logic    [63:0]  rdata_sram_output,

    output  logic    [31:0]  CONTROL,
    input   logic    [31:0]  STATUS

);

assign icb_rsp_err = 1'b0;

// cmd ready, icb_cmd_ready
always_ff @(posedge clk)
begin
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
        end
    end
end

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
        {csbn_sram_input, csbn_sram_wq0, csbn_sram_wq1, csbn_sram_wk0, csbn_sram_wk1, csbn_sram_wv0, csbn_sram_wv1} <= 7'b111_1111;
        {waddr_sram_input, waddr_sram_wq0, waddr_sram_wq1, waddr_sram_wk0, waddr_sram_wk1, waddr_sram_wv0, waddr_sram_wv1} <= 84'b0;
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready & !icb_cmd_read & (offset >= `INPUT_ADDR) & (offset < `CONTROL_ADDR)) begin
            if (offset < `WQ0_ADDR) begin
                wsbn_sram_input <= wdata_valid ? 1'b0 : 1'b1;
                csbn_sram_input <= wdata_valid ? 1'b0 : 1'b1;
                waddr_sram_input <= offset - `INPUT_ADDR;
            end
            else if(offset < `WQ1_ADDR) begin
                wsbn_sram_wq0   <= wdata_valid ? 1'b0 : 1'b1;
                csbn_sram_wq0   <= wdata_valid ? 1'b0 : 1'b1;
                waddr_sram_wq0  <= offset - `WQ0_ADDR;
            end
            else if(offset < `WK0_ADDR) begin
                wsbn_sram_wq1   <= wdata_valid ? 1'b0 : 1'b1;
                csbn_sram_wq1   <= wdata_valid ? 1'b0 : 1'b1;
                waddr_sram_wq1  <= offset - `WQ1_ADDR;
            end
            else if(offset < `WK1_ADDR) begin
                wsbn_sram_wk0   <= wdata_valid ? 1'b0 : 1'b1;
                csbn_sram_wk0   <= wdata_valid ? 1'b0 : 1'b1;
                waddr_sram_wk0  <= offset - `WK0_ADDR;
            end
            else if(offset < `WV0_ADDR) begin
                wsbn_sram_wk1   <= wdata_valid ? 1'b0 : 1'b1;
                csbn_sram_wk1   <= wdata_valid ? 1'b0 : 1'b1;
                waddr_sram_wk1  <= offset - `WK1_ADDR;
            end
            else if(offset < `WV1_ADDR) begin
                wsbn_sram_wv0   <= wdata_valid ? 1'b0 : 1'b1;
                csbn_sram_wv0   <= wdata_valid ? 1'b0 : 1'b1;
                waddr_sram_wv0  <= offset - `WV0_ADDR;
            end
            else if(offset < `CONTROL_ADDR) begin
                wsbn_sram_wv1   <= wdata_valid ? 1'b0 : 1'b1;
                csbn_sram_wv1   <= wdata_valid ? 1'b0 : 1'b1;
                waddr_sram_wv1  <= offset - `WV1_ADDR;
            end
        end
        else begin
            {wsbn_sram_input, wsbn_sram_wq0, wsbn_sram_wq1, wsbn_sram_wk0, wsbn_sram_wk1, wsbn_sram_wv0, wsbn_sram_wv1} <= {wsbn_sram_input, wsbn_sram_wq0, wsbn_sram_wq1, wsbn_sram_wk0, wsbn_sram_wk1, wsbn_sram_wv0, wsbn_sram_wv1};
            {csbn_sram_input, csbn_sram_wq0, csbn_sram_wq1, csbn_sram_wk0, csbn_sram_wk1, csbn_sram_wv0, csbn_sram_wv1} <= {csbn_sram_input, csbn_sram_wq0, csbn_sram_wq1, csbn_sram_wk0, csbn_sram_wk1, csbn_sram_wv0, csbn_sram_wv1};
            {waddr_sram_input, waddr_sram_wq0, waddr_sram_wq1, waddr_sram_wk0, waddr_sram_wk1, waddr_sram_wv0, waddr_sram_wv1} <= {waddr_sram_input, waddr_sram_wq0, waddr_sram_wq1, waddr_sram_wk0, waddr_sram_wk1, waddr_sram_wv0, waddr_sram_wv1};
        end
    end
end


// response valid, icb_rsp_valid, delay one clock
logic icb_rsp_valid_r;
always_ff @(posedge clk)
begin
    if(!rst_n) begin
        icb_rsp_valid_r <= 1'h0;
        icb_rsp_valid <= 1'h0;
    end
    else if(~icb_cmd_read) begin
        icb_rsp_valid_r <= icb_rsp_valid_r;
        if(icb_cmd_valid & icb_cmd_ready) begin
            icb_rsp_valid <= 1'h1;
        end
        else if(icb_rsp_valid_r & icb_rsp_ready) begin
            icb_rsp_valid <= 1'h0;
        end
        else begin
            icb_rsp_valid <= icb_rsp_valid;
        end
    end
    else begin
        if(icb_cmd_valid & icb_cmd_ready) begin
            icb_rsp_valid_r <= 1'h1;
            icb_rsp_valid   <= icb_rsp_valid_r;
        end
        else if(icb_rsp_valid_r & icb_rsp_ready) begin
            icb_rsp_valid_r <= 1'h0;
            icb_rsp_valid   <= icb_rsp_valid_r;
        end
        else begin
            icb_rsp_valid_r <= icb_rsp_valid_r;
            icb_rsp_valid   <= icb_rsp_valid_r;
        end
    end
end


// read data, icb_rsp_rdata
logic rdata_valid;

assign csbn_sram_output  = (icb_cmd_read & (offset < `WQ0_ADDR)) ? 1'b0 : 1'b1;
assign raddr_sram_output = (icb_cmd_read & (offset < `WQ0_ADDR)) ? offset - `INPUT_ADDR : 12'b0;

always_ff @(posedge clk)
begin
    if(!rst_n) begin
        icb_rsp_rdata <= 32'h0;
        rdata_valid   <= 1'h0;
    end
    else begin
        if(icb_rsp_valid_r & icb_cmd_read & (offset >= `CONTROL_ADDR)) begin
            case(icb_cmd_addr[11:0])
                `CONTROL_ADDR:  icb_rsp_rdata   <= CONTROL;
                `STATUS_ADDR:   icb_rsp_rdata   <= STATUS;
            endcase
        end
        else if (icb_rsp_valid_r & icb_cmd_read & (offset >= `INPUT_ADDR) & (offset < `WQ0_ADDR)) begin
            icb_rsp_rdata <= rdata_valid ? rdata_sram_output[63:32] : rdata_sram_output[31:0];
            rdata_valid   <= ~rdata_valid;
        end  
        else begin
            icb_rsp_rdata <= 32'h0;
            rdata_valid   <= rdata_valid;
        end
    end
end

endmodule
