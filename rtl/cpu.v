module cpu (
    input clk,
    input rst,

    // memory interface
    input [7:0] mem_data_in,  // data read from memory
    output [7:0] mem_addr,  // address bus
    output [7:0] mem_data_out,  // data written to memory
    output mem_write,
    output mem_read
);

  // internal signals
  wire [7:0] pc_addr;  // address from PC
  wire [7:0] reg_a, reg_b;
  wire zero_flag, carry_flag;

  wire [2:0] alu_op;
  wire [1:0] reg_sel, data_src;
  wire reg_write;
  wire pc_load, pc_inc;
  wire [2:0] state;

  wire [7:0] alu_result;
  wire alu_zero, alu_carry;

  wire flag_update;
  wire [7:0] write_data;

  reg [7:0] ir;
  reg [7:0] addr_reg;  // for multi-byte instruction

  wire [3:0] instr_type = ir[7:4];
  wire [3:0] instr_code = ir[3:0];

  // state tracking to know when we need to fetch address/immediate
  wire needs_operand = (instr_type == 4'h2) ||  // memory
  (instr_type == 4'h3) ||  // jumps
  (instr_type == 4'h1 && (instr_code == 4'h2 || instr_code == 4'h3));

  pc pc_inst (
      .clk(clk),
      .rst(rst),
      .load_addr(addr_reg),  // load from instruction immediate
      .load_en(pc_load),
      .inc_en(pc_inc),
      .addr(pc_addr)
  );

  registers reg_file (
      .clk(clk),
      .rst(rst),
      .data_in(write_data),
      .reg_sel(reg_sel),
      .write_en(reg_write),
      .reg_a(reg_a),
      .reg_b(reg_b),
      .zero_flag(zero_flag),
      .carry_flag(carry_flag),
      .zero_in(alu_zero),
      .carry_in(alu_carry),
      .flag_update(flag_update)
  );

  alu alu_inst (
      .a(reg_a),
      .b(reg_b),
      .op(alu_op),
      .result(alu_result),
      .zero(alu_zero),
      .carry(alu_carry)
  );

  control ctrl_inst (
      .clk(clk),
      .rst(rst),
      .instr(ir),
      .zero_flag(zero_flag),
      .carry_flag(carry_flag),
      .alu_op(alu_op),
      .reg_sel(reg_sel),
      .reg_write(reg_write),
      .data_src(data_src),
      .pc_load(pc_load),
      .pc_inc(pc_inc),
      .mem_write(mem_write),
      .mem_read(mem_read),
      .state(state)
  );

  // fetch instruction from memory
  assign mem_addr = (mem_read || mem_write) ? addr_reg : pc_addr;

  // instruction fetch and decode logic
  always @(posedge clk) begin
    if (rst) begin
      ir <= 8'b0;
      addr_reg <= 8'b0;
    end else if (state == 3'b000) begin  // while in FETCH, latch next cycle
      ir <= mem_data_in;
    end else if (state == 3'b101) begin
      addr_reg <= mem_data_in;
    end
  end

  // data path multiplexer for register writes
  assign write_data = (data_src == 2'b00) ? alu_result :
    (data_src == 2'b01) ? addr_reg :
    (data_src == 2'b10) ? mem_data_in :
    (data_src == 2'b11) ? ((reg_sel == 2'b00) ? reg_b : reg_a) :
    8'b0;

  // flag update
  assign flag_update = (state == 3'b010);  // after execute

  // memory outputs
  assign mem_data_out = reg_a;
endmodule
