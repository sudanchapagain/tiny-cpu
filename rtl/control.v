module control (
    input clk,
    input rst,

    // current instruction
    input [7:0] instr,

    // ALU result flags
    input zero_flag,
    input carry_flag,

    output reg [2:0] alu_op,

    // register control
    output reg [1:0] reg_sel,  // which reg to write
    output reg reg_write,  // enable write
    output reg [1:0] data_src,  // where data comes from. 00=alu, 01=immediate, 10=memory, 11=other_reg

    // program counter
    output reg pc_load,
    output reg pc_inc,

    // memory control signals
    output reg mem_write,
    output reg mem_read,

    output reg [2:0] state  // cpu state
);
  // instruction cycle states
  localparam [2:0] FETCH = 3'b000;
  localparam [2:0] DECODE = 3'b001;
  localparam [2:0] EXECUTE = 3'b010;
  localparam [2:0] WRITEBACK = 3'b011;
  localparam [2:0] HALT = 3'b100;
  localparam [2:0] OPERAND = 3'b101;

  // decode instruction
  // [ type ][ code ]
  //   4bit     4bit
  // 0000 0000 -> ADD
  wire [3:0] instr_type = instr[7:4];
  wire [3:0] instr_code = instr[3:0];

  always @(posedge clk) begin
    // on reset fetch instruction with all registers zero-ed. self explanatory really
    if (rst) begin
      state <= FETCH;
      alu_op <= 3'b000;
      reg_write <= 1'b0;
      pc_inc <= 1'b0;
      pc_load <= 1'b0;
      mem_write <= 1'b0;
      mem_read <= 1'b0;
    end else begin
      case (state)
        FETCH: begin
          pc_inc <= 1'b1;  // +1 PC
          state  <= DECODE;  // ...
        end

        DECODE: begin
          pc_inc <= 1'b0;  // MVI cases below will re-set to 1
          if (instr == 8'hFF) begin  // if hlt instruction: halt.
            state <= HALT;

          end else if (instr_type == 4'h0) begin // see README on what was assigned the instruction.
                                                 // 0X are arithmetic
            case (instr_code)
              4'h0: alu_op <= 3'b000;  // ADD
              4'h1: alu_op <= 3'b001;  // SUB
              4'h2: alu_op <= 3'b010;  // AND
              4'h3: alu_op <= 3'b011;  // OR
              4'h4: alu_op <= 3'b100;  // XOR
            endcase
            reg_sel <= 2'b00;  // write to reg A
            data_src <= 2'b00;  // source as ALU
            state <= EXECUTE;

          end else if (instr_type == 4'h1) begin  // data movement.
            case (instr_code)
              4'h0: begin  // MOV A,B
                reg_sel <= 2'b00;  // select A for write
                data_src <= 2'b11;  // from B register
                state <= EXECUTE;
              end
              4'h1: begin  // MOV B,A
                reg_sel <= 2'b01;  // select B for write
                data_src <= 2'b11;  // from A register
                state <= EXECUTE;
              end
              4'h2: begin  // MVI A, imm
                reg_sel <= 2'b00;  // write A
                data_src <= 2'b01;  // immediate (addr_reg)
                pc_inc <= 1'b1;  // +PC to operand byte
                state <= OPERAND;
              end
              4'h3: begin  // MVI B, imm
                reg_sel <= 2'b01;  // write B
                data_src <= 2'b01;
                pc_inc <= 1'b1;
                state <= OPERAND;
              end
            endcase

          end else if (instr_type == 4'h2) begin  // memory
            case (instr_code)
              4'h0: begin  // LDA addr
                reg_sel <= 2'b00;  // write A
                data_src <= 2'b10;  // memory
                mem_read <= 1'b1;
                state <= EXECUTE;
              end
              4'h1: begin  // STA addr
                // mem_write <= 1'b1;
                pc_inc <= 1'b1;
                state  <= OPERAND;
              end
            endcase

          end else if (instr_type == 4'h3) begin  // control flow
            case (instr_code)
              4'h0: begin  // JMP (unconditional)
                pc_load <= 1'b1;  // load new address (see: pc.v)
                state   <= FETCH;  // fetch new address. ;-;
              end
              4'h1: begin  // JZ (if zero)
                if (zero_flag) pc_load <= 1'b1;  // if last cycle had zero flag set then load pc.
                state <= FETCH;
              end
              4'h2: begin  // JNZ (if not zero)
                if (!zero_flag) pc_load <= 1'b1;  // opposite of above condition.
                state <= FETCH;
              end
            endcase

          end else begin  // unknown instructions. ;-;
            state <= FETCH;
          end
        end

        OPERAND: begin
          pc_inc <= 1'b0;
          state  <= EXECUTE;
        end

        EXECUTE: begin
          pc_inc   <= 1'b0;
          mem_read <= 1'b0;
          pc_load  <= 1'b0;
          if (instr_type == 4'h2 && instr_code == 4'h1) begin
            mem_write <= 1'b1;
            reg_write <= 1'b0;
          end else begin
            mem_write <= 1'b0;
            reg_write <= 1'b1;
          end
          state <= WRITEBACK;
        end

        WRITEBACK: begin
          reg_write <= 1'b0;
          mem_write <= 1'b0;
          state <= FETCH;
        end

        HALT: begin
        end

        default: state <= FETCH;
      endcase
    end
  end
endmodule
