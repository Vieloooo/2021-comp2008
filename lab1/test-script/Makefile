all: div.v top.v testTop.cpp
	verilator -cc --exe --build testTop.cpp top.v div.v -Wno-style -Wno-lint --trace

run: all
	obj_dir/Vtop

debug: run
	gtkwave wave.vcd >/dev/null 2>&1 & 

clean:
	rm -rf obj_dir wave.vcd


