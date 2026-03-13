module pc (
    input clk,
    input rst,

    input [7:0] load_addr,
    input load_en,
    input inc_en,

    output reg [7:0] addr
);

  always @(posedge clk) begin
    if (rst) begin
      addr <= 8'b0;  // on reset address is 0
    end else if (load_en) begin  // on load signal, load address
      addr <= load_addr;
    end else if (inc_en) begin  // on inc signal, increment duh.
      addr <= addr + 1;
    end
  end

endmodule
