module dut (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [1:0] op,
    output reg  [3:0] result,
    output reg        carry_borrow
);

    always @(*) begin
        case (op)
            2'b00: {carry_borrow, result} = {1'b0, a} + {1'b0, b};
            2'b01: {carry_borrow, result} = {1'b0, a} - {1'b0, b};
            2'b10: begin
                result = a & b;
                carry_borrow = 1'b0;
            end
            2'b11: begin
                result = a | b;
                carry_borrow = 1'b0;
            end
            default: begin
                result = 4'b0000;
                carry_borrow = 1'b0;
            end
        endcase
    end

endmodule
