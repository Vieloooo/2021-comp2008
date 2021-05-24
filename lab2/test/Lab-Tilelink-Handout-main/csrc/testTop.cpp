#include "dut.h"
#include "verilated.h"
#include "Vtop.h"
#include <stdio.h>

#define CONFIG_ADDR 0x0
#define PHASE_ADDR  0x1
#define RESULT_ADDR 0x2

#define SIN 0
#define COS 1
TESTBENCH<Vtop>* top;
Vtop* top_module;

// Example testbench
// You can add yours below
__uint32_t testdata[][3] = {
	/* { function, phase, result } */
	{SIN, 0x1000a, 0xfc1b},
	{SIN, 0x10014, 0xf08c},
	{COS, 0x1000a, 0xffffd38d},
	{COS, 0x10014, 0xffffa872}
};


void reset_all(){
	printf("Resetting ...\n");
	top_module -> rst_n = 0;
	for(int i = 0; i<20; i++) {
		top -> tick();
	}
	top_module -> rst_n = 1;
	for(int i = 0; i<20; i++) {
		top -> tick();
	}
	printf("Reset done.\n");
}

void write(__uint32_t addr, __uint32_t wdata) {
	top_module -> byte_en = 0xf;
	// Write the phase
	top_module -> wr = 1;
	top_module -> addr = addr;
	top_module -> wdata = wdata;
	top -> tick();
	top_module -> wr = 0;
	// Wait for ~5 cycles for transfer to finish
	for(int i = 0; i < 5; i++) {
		top -> tick();
	}
}

__uint32_t read(__uint32_t addr) {
	top_module -> byte_en = 0xf;
	top_module -> rd = 1;
	top_module -> addr = addr;
	top -> tick();
	top_module -> rd = 0;
	int cnt = 0;
	do {
		top -> tick();
		cnt += 1;
		if(cnt >= 10) {
			printf("Waiting rdata for too long!\n");
			exit(0);
		}
	} while(top_module -> rdata_v == 0);
	__uint32_t ret = top_module -> rdata;
	for(int i = 0; i < 5; i++) {
		top -> tick();
	}
	return ret;
}

__uint32_t test(int func, __uint32_t phase, __uint32_t result) {
	write(PHASE_ADDR, phase); // Write the phase
	write(CONFIG_ADDR, (1 | (func << 8))); // Start the module
	// Wait ~30 cycs for computation to finish
	for(int i = 0; i < 30; i++) {
		top -> tick();
	}
	return read(RESULT_ADDR);
}

int main(int argc, char** argv, char** env) {
	top = new TESTBENCH<Vtop>;
	top -> opentrace("debug.vcd");
	top_module = top -> dut;

	reset_all();

	printf("Test Start!\n");
	int num_testpoint_passed = 0;
	int num_testpoint = (sizeof(testdata)/sizeof(__uint32_t)) / (sizeof(testdata[0])/sizeof(__uint32_t));
	for(int i = 0; i < num_testpoint; i++) {
		printf("Testpoint %d, ", i);
		if(testdata[i][0] == 0) printf("sin"); else printf("cos");
		printf("(0x%x). ", testdata[i][1]);
		printf("Expected 0x%x, ", testdata[i][2]);
		int testret = test(testdata[i][0], testdata[i][1], testdata[i][2]);
		printf("got 0x%x. ", testret);
		if(testret == testdata[i][2]) { 
			printf("PASSED!");
			num_testpoint_passed += 1;
		} else {
			printf("FAILED!");
		}
		printf("\n");
	}
	printf("Passed %d of %d testpoints.\n", num_testpoint_passed, num_testpoint);
	delete top;
	return 0;
}

