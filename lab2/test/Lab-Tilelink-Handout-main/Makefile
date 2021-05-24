all: slave.v rtl/*.v csrc/*
	verilator -cc --exe --build rtl/*.v slave.v csrc/testTop.cpp --top top -Wno-style -Wno-lint --trace
run: all
	obj_dir/Vtop
debug: all
	obj_dir/Vtop
	gtkwave debug.vcd > debug.log 2>&1  & 
clean:
	rm -rf obj_dir debug.vcd debug.log
