`timescale 1ns / 1ps

module tb_cpu;
  reg clk;
  reg rst;

  wire [7:0] mem_addr;
  wire [7:0] mem_data_in;
  assign mem_data_in = mem[mem_addr];
  wire [7:0] mem_data_out;
  wire mem_write;
  wire mem_read;

  cpu uut (
      .clk(clk),
      .rst(rst),
      .mem_data_in(mem_data_in),
      .mem_addr(mem_addr),
      .mem_data_out(mem_data_out),
      .mem_write(mem_write),
      .mem_read(mem_read)
  );

  // 256-byte mem
  reg [7:0] mem[0:255];
  integer i;  // temp

  // clock generation: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    // clear mem
    for (i = 0; i < 256; i = i + 1) mem[i] = 8'b0;

    // program:
    // 0: MVI A, 10
    // 2: MVI B, 20
    // 4: ADD B
    // 5: STA 0xF0
    // 7: HLT
    mem[0] = 8'h12;  // MVI A, imm
    mem[1] = 8'h0A;  // immediate 10
    mem[2] = 8'h13;  // MVI B, imm
    mem[3] = 8'h14;  // immediate 20
    mem[4] = 8'h00;  // ADD B
    mem[5] = 8'h21;  // STA addr
    mem[6] = 8'hF0;  // address F0
    mem[7] = 8'hFF;  // HLT
  end

  // memory data to CPU
  always @(negedge clk) begin
    if (mem_write) mem[mem_addr] <= mem_data_out;
  end


  // reset sequence
  initial begin
    rst = 1;
    #10;
    rst = 0;
  end

  // CPU state
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_cpu);
    $display("| Time | PC | IR | A | B | Mem[F0] |");
    $display("| ---- | -- | -- | - | - | ------- |");
    $monitor("| %0t | %h | %h | %h | %h | %h |", $time, uut.pc_addr, uut.ir, uut.reg_a, uut.reg_b,
             mem[8'hF0]);
    #300;
    $display("--- Final state ---");
    $display("A=%h B=%h Mem[F0]=%h", uut.reg_a, uut.reg_b, mem[8'hF0]);
    $finish;
  end
endmodule
