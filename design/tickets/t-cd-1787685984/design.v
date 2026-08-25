module dut (
    input  wire       clk,
    input  wire       rst,   // Synchronous reset
    input  wire       up,    // Direction: 1 = count up, 0 = count down
    output reg  [2:0] count
);

    always @(posedge clk) begin
        if (rst) begin
            count <= 3'b000;
        end else if (up) begin
            count <= count + 3'b001;
        end else begin
            count <= count - 3'b001;
        end
    end

endmodule
