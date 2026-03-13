module alu (
    // two 8bit input and 3 bit operation selector
    input [7:0] a,
    input [7:0] b,
    input [2:0] op,

    output reg [7:0] result,
    output zero,
    output reg carry
);
  always @(*) begin
    carry = 0;

    case (op)
      3'b000:  {carry, result} = a + b;
      3'b001:  {carry, result} = a - b;
      3'b010:  result = a & b;
      3'b011:  result = a | b;
      3'b100:  result = a ^ b;
      default: result = 8'b00000000;
    endcase
  end

  // if 0, raise zero flag
  assign zero = (result == 8'b00000000);
endmodule
