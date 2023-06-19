module acc_top #(
    parameter INIT_ROW = "",
    parameter INIT_COL = ""
)

(
    // clk & rst_n
    input           clk,
    input           rst_n,

    input               icb_cmd_valid,
    output  reg         icb_cmd_ready,
    input               icb_cmd_read,
    input       [31:0]  icb_cmd_addr,
    input       [31:0]  icb_cmd_wdata,
    input       [3:0]   icb_cmd_wmask,

    output  reg         icb_rsp_valid,
    input               icb_rsp_ready,
    output  reg [31:0]  icb_rsp_rdata,
    output              icb_rsp_err
);

logic [15:0] STAT_REG_WR, STAT_REG_RD;
logic [31:0] CONFIG_REG, CALCBASE_REG, RWBASE_REG, WBBASE_REG;

logic [12:0] sram_wr_addr, sram_rd_addr;
logic [31:0] sram_wr_data, sram_rd_data;

icb_slave u_icb_slave (
    .clk(clk),
    .rst_n(rst_n),

    .icb_cmd_valid(icb_cmd_valid),
    .icb_cmd_ready(icb_cmd_ready),
    .icb_cmd_read(icb_cmd_read),
    .icb_cmd_addr(icb_cmd_addr),
    .icb_cmd_wdata(icb_cmd_wdata),
    .icb_cmd_wmask(icb_cmd_wmask),
    .icb_rsp_valid(icb_rsp_valid),
    .icb_rsp_ready(icb_rsp_ready),
    .icb_rsp_rdata(icb_rsp_rdata),
    .icb_rsp_err(icb_rsp_err),

    .STAT_REG_WR(STAT_REG_WR),
    .CONFIG_REG(CONFIG_REG),
    .CALCBASE_REG(CALCBASE_REG),
    .RWBASE_REG(RWBASE_REG),
    .STAT_REG_RD(STAT_REG_RD),

    .sram_wr_data(sram_wr_data),
    .sram_wr_addr(sram_wr_addr),
    .sram_wr_en(sram_wr_en),
    .sram_rd_data(sram_rd_data),
    .sram_rd_addr(sram_rd_addr),
    .sram_rd_en(sram_rd_en)

);

// STAT_REG [0]-start_all, [16]-done_all
// CONFIG_REG [0]-out_mode, [1]-write_mode, [2]-read_mode, [3]-sram_cs, [8:15]-k_param, [16:23]-row_shape, [24:31]-col_shape
// CALCBASE_REG [0:12]-calc_row_addr [16:28]-calc_col_addr
// RWBASE_REG [0:12]-rw_row_addr [16:28]-rw_col_addr

logic ren_n, wen_n, csbn_row, csbn_col, wsbn_row, wsbn_col;
logic [12:0] raddr_row_sram, raddr_col_sram;
logic [31:0] rdata_row, rdata_col, wdata_row, wdata_col, data_out;
logic [12:0] waddr, raddr_row, raddr_col, waddr_row, waddr_col;

always_comb begin
    if (!CONFIG_REG[3]) begin //selected
        if (CONFIG_REG[1]) begin //write_mode
            wsbn_row = !sram_wr_en;
            waddr_row = sram_wr_addr+RWBASE_REG[12:0];
            wdata_row = sram_wr_data;
        end
        else begin // calc_mode, get data from SA
            wsbn_row = wen_n;
            waddr_row = waddr+STAT_REG_WR[13:1];
            wdata_row = data_out;
        end
    end
    else begin
        wsbn_row = 1;
        waddr_row = 0;
        wdata_row = 0;
    end
end

assign rd_row = CONFIG_REG[2] ? !sram_rd_en:ren_n;
assign raddr_row_sram = CONFIG_REG[2]? sram_rd_addr+RWBASE_REG[12:0]: raddr_row + CALCBASE_REG[12:0];
assign csbn_row = wsbn_row && rd_row;

sram_8k_32b #(.INIT(INIT_ROW)) //save input data
u_sram_row (
    .clk(clk),
    .wsbn(wsbn_row),
    .waddr(waddr_row),
    .wdata(wdata_row),
    .csbn(csbn_row),
    .raddr(raddr_row_sram),
    .rdata(rdata_row)
);

always_comb begin
    if (CONFIG_REG[3]) begin //selected
        if (CONFIG_REG[1]) begin //write_mode
            wsbn_col = !sram_wr_en;
            waddr_col = sram_wr_addr+RWBASE_REG[28:16];
            wdata_col = sram_wr_data;
        end
        else begin // calc_mode, get data from SA
            wsbn_col = wen_n;
            waddr_col = waddr+STAT_REG_WR[13:1];
            wdata_col = data_out;
        end
    end
    else begin
        wsbn_col = 1;
        waddr_col = 0;
        wdata_col = 0;
    end
end

assign rd_col = CONFIG_REG[2] ? !sram_rd_en:ren_n;
assign raddr_col_sram = CONFIG_REG[2]? sram_rd_addr+RWBASE_REG[28:16]: raddr_col + CALCBASE_REG[28:16];
assign csbn_col = wsbn_col && rd_col;

sram_8k_32b #(.INIT(INIT_COL)) //save input data
u_sram_col (
    .clk(clk),
    .wsbn(1'b1),
    .waddr('b0),
    .wdata('b0),
    .csbn(ren_n),
    .raddr(raddr_col_sram),
    .rdata(rdata_col)
);

assign sram_rd_data = CONFIG_REG[3]? rdata_col:rdata_row;

logic done_all;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        STAT_REG_RD <= 0;
    end
    else begin
        if (done_all) begin
            STAT_REG_RD <= 1;
        end
        else if (STAT_REG_WR[0]) begin
            STAT_REG_RD <= 0;
        end
    end
end

SA_with_shift_cfg #(.N(4))
u_SA(.clk(clk),.rst_n(rst_n),
    .start_all(STAT_REG_WR[0]),.out_mode(CONFIG_REG[0]),.done_all(done_all),
    .k_param(CONFIG_REG[15:8]),.row_shape(CONFIG_REG[23:16]),.col_shape(CONFIG_REG[31:24]),
    .ren_n(ren_n),.raddr_row(raddr_row),.raddr_col(raddr_col),
    .rdata_row(rdata_row),.rdata_col(rdata_col),
    .wen_n(wen_n),.waddr(waddr),
    .data_out(data_out)
);

endmodule