module dut (
    input  wire       clk,
    input  wire       rst,  // Synchronous reset, active high
    input  wire       din,  // Serial data input
    output reg  [7:0] dout  // Parallel data output
);

    always @(posedge clk) begin
        if (rst) begin
            dout <= 8'h00;
        end else begin
            dout <= {dout[6:0], din};
        end
    end

endmodule
