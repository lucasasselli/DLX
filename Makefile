all: dlx testbench

# Compile globals
globals:
	vcom Source/000-globals.vhd

# Compile datapath
datapath: globals
	vcom Source/a.a-DataPath.core/*.vhd Source/a.a-DataPath.core/a.b-alu.core/*.vhd Source/a.a-DataPath.vhd

# Compile control unit
cu: globals
	vcom Source/a.b-ControlUnit.vhd

dlx: globals datapath cu
	vcom Source/a-DLX.vhd

testbench: globals
	vcom Testbench/dlx/*.vhd Testbench/alu/*.vhd

# Deletes the work folder
clean:
	rm -r -f work

# Creates the work folder
init:
	vlib work
