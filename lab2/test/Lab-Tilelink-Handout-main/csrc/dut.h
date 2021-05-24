#ifndef __DUT__
#define __DUT__

#include <verilated_vcd_c.h>

template<class MODULE> class TESTBENCH {
		public:
		VerilatedVcdC	*vltdump;
		MODULE *dut;
		unsigned long count;

		TESTBENCH(void) {
				Verilated::traceEverOn(true);
				dut = new MODULE;
				count = 0;
		}

		~TESTBENCH(void) {
				closetrace();
				if(!vltdump) delete vltdump;
				delete dut;
		}

		// Open/create a trace file
		void opentrace(const char *vcdname) {
				if (!vltdump) {
						vltdump = new VerilatedVcdC;
						dut->trace(vltdump, 99);
						vltdump->open(vcdname);
				}
		}

		// Close a trace file
		void closetrace(void) {
				if (vltdump) {
						vltdump->close();
						vltdump = NULL;
				}
		}

		void tick(void) {
				count++;

				dut->clk = 0;
				dut->eval();

				if(vltdump) vltdump->dump(10*count-1);

				// Repeat for the positive edge of the clock
				dut->clk = 1;
				dut->eval();
				if(vltdump) vltdump->dump(10*count);

				// Now the negative edge
				dut->clk = 0;
				dut->eval();
				if (vltdump) {
						vltdump->dump(10*count+5);
						vltdump->flush();
				}
		}
};
#endif
