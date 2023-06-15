module sram_4k_64b(
    input clk,

    // write port
    input logic wsbn, //write enable, active low
    input logic [12:0] waddr,
    input logic [31:0] wdata,

    //read port
    input  logic csbn, //read enable, active low
    input  logic [12:0] raddr,
    output logic [31:0] rdata
);

logic [8191:0] mem[31:0];

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