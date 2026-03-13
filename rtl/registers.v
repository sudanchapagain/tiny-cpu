module registers (
    input clk,
    input rst,

    input [7:0] data_in,
    input [1:0] reg_sel,  // 00=A, 01=B
    input write_en,

    output reg [7:0] reg_a,
    output reg [7:0] reg_b,
    output reg zero_flag,
    output reg carry_flag,

    input zero_in,
    input carry_in,
    input flag_update
);

  always @(posedge clk) begin
    if (rst) begin
      reg_a <= 8'b0;
      reg_b <= 8'b0;
      zero_flag <= 1'b0;
      carry_flag <= 1'b0;
    end else begin
      // flag updates
      if (flag_update) begin
        zero_flag  <= zero_in;
        carry_flag <= carry_in;
      end

      // register writes
      if (write_en) begin
        case (reg_sel)
          2'b00:   reg_a <= data_in;
          2'b01:   reg_b <= data_in;
          default: ;
        endcase
      end
    end
  end
endmodule
