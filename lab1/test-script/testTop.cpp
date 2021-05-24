#include "Vtop.h"
#include <stdio.h>
#include "verilated.h"
#include <verilated_vcd_c.h>
vluint64_t count = 0;
double sc_time_stamp () {
	return count;
}
char x[] = { 20 };
char y[] = { 3 };
char z[] = { 6 };
char r[] = { 2 };
VerilatedVcdC* tfp;
Vtop* top;
int test(char x, char y, char z, char r, Vtop* dut) {
	int cyc = 0;
	dut -> x = x;
	dut -> y = y;
	dut -> clk = 0;
	dut -> eval();
	dut -> start = 1;
	dut -> clk = 1;
	dut -> eval();
	tfp -> dump(count++);
	dut -> clk = 0;
	dut -> eval();
	tfp -> dump(count++);
	dut -> start  = 0;
	do {
		dut -> clk = 1;
		dut -> eval();
		tfp -> dump(count++);
		dut -> clk = 0;
		dut -> eval();
		tfp -> dump(count++);
		if(cyc ++ > 10) {
			printf("Busy is keeping high for more than 10 cycles, pleas check your design\n");
			return -2;
		}
	} while(dut -> busy == 1);
	int rr_correct = 1;
	int as_correct = 1;
	if(dut -> z1 != z || dut -> r1 != r) {
		printf("Result z1 or r1 is wrong! Please check your div_rr\n");
		printf("x = 0x%x, y = 0x%x.\n Ref: z = 0x%x, r = 0x%x\n Your: z1 = 0x%x, r1 = 0x%x\n", x, y, z, r, dut->z1, dut->r1);
		rr_correct = 0;
	}
	if(dut -> z2 != z || dut -> r2 != r) {
		printf("Result z2 or r2 is wrong! Please check your div_as\n");
		printf("x = 0x%x, y = 0x%x.\n Ref: z = 0x%x, r = 0x%x\n Your: z2 = 0x%x, r2 = 0x%x\n", x, y, z, r, dut->z2, dut->r2);
		as_correct = 0;
	}
	if(rr_correct && as_correct) return 2;
	if(rr_correct && !as_correct) return 1;
	if(!rr_correct && as_correct) return -1;
	if(!rr_correct && !as_correct) return -2;
	return 0;
}

int main(int argc, char** argv, char** env) {
	Verilated::traceEverOn(true);
	top = new Vtop;
	tfp = new VerilatedVcdC;
	top->trace(tfp, 99);
	tfp->open("wave.vcd");
	int score = 100;
	top -> rst_n = 0;
	top -> clk = 0;
	printf("Resetting....\n");
	for(int i = 0; i<20; i++) {
		top -> clk = 1;
		top -> eval();
		tfp -> dump(count++);
		top -> clk = 0;
		top -> eval();
		tfp -> dump(count++);
	}
         
	top -> rst_n = 1;
	for(int i = 0; i<20; i++) {
		top -> clk = 1;
		top -> eval();
		tfp -> dump(count++);
		top -> clk = 0;
		top -> eval();
		tfp -> dump(count++);
	}
	printf("Test Start!\n");
	int score_rr = 50, score_as = 50;
	for(int i = 0; i< sizeof(x)/sizeof(x[0]); i++) {
			int ret = test(x[i], y[i], z[i], r[i], top);
			switch(ret){
				case 1: score_as = 0; break;
				case -1: score_rr = 0; break;
				case -2: score_as = 0; score_rr = 0; break;
			}	
	}
	tfp->close();
	delete tfp;
	delete top;
	if(score_rr == 50) {
		printf("TEST div_rr PASSED!!!!\n");
	}
	if(score_as == 50) {
		printf("TEST div_as PASSED!!!!\n");
	}
	return 0;
}

