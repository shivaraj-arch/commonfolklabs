// Synthesizable 8x8 RAM (8 words, 8 bits per word)
module dut (
    input wire clk,
    input wire we,
    input wire [2:0] addr,
    input wire [7:0] din,
    output wire [7:0] dout
);

    // 8 words of 8-bit memory
    reg [7:0] ram [0:7];

    // Synchronous write port
    always @(posedge clk) begin
        if (we) begin
            ram[addr] <= din;
        end
    end

    // Asynchronous read port
    assign dout = ram[addr];

endmodule
