run:
	mkdir -p build
	iverilog -o build/sim.out rtl/*.v sim/tb_cpu.v
	vvp build/sim.out

runview:
	mkdir -p build
	iverilog -o build/sim.out rtl/*.v sim/tb_cpu.v
	vvp build/sim.out
	gtkwave dump.vcd

lint:
	verible-verilog-lint rtl/*.v

format:
	verible-verilog-format rtl/*.v --inplace
	verible-verilog-format sim/*.v --inplace

schema:
	yosys -p "read_verilog rtl/*.v; hierarchy -top cpu; proc; flatten; opt; show cpu"

genimage:
	yosys -p "read_verilog rtl/*.v; hierarchy -top cpu; proc; opt; show -format svg -prefix schematic cpu"

