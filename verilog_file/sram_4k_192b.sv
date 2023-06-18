module sram_4k_192b
(
    input clk,

    // write port
    input logic wsbn, //write enable, active low
    input logic [11:0] waddr,
    input logic [159:0] wdata,

    //read port
    input  logic csbn, //read enable, active low
    input  logic [11:0] raddr,
    output logic [191:0] rdata
);

logic [191:0] mem[4096];

always_ff @(posedge clk) begin: write
    if(!csbn && !wsbn) begin
        mem[waddr] <= wdata;
    end
end

always_ff @(posedge clk) begin: read
    if(!csbn) begin
        rdata <= mem[raddr];
    end
end

endmodule