module top_sim();
reg clk = 0;
reg rst_n = 'b0;
reg wr,rd;
reg [3:0] bytes,addr;
reg [31:0] wdata; 
wire rdata_v;
wire [31:0] rdata;
top toptest(
    .clk(clk),
    .rst_n(rst_n),
    .wr(wr),
    .rd(rd),
    .byte(bytes),
    .addr(addr),
    .wdata(wdata),
    .rdata_v(rdata_v),
    .rdata(rdata)
);
always #5 clk = ~clk;
initial begin
// c
    // start rst 
    /* test case cases
    {SIN, 0x1000a, 0xfc1b},
	{SIN, 0x10014, 0xf08c},
	{COS, 0x1000a, 0xffffd38d},
	{COS, 0x10014, 0xffffa872}
    */
    #20 rst_n = 'b1;  rd= 'b0; wr= 'b0; bytes= 'h0;addr= 'h0;wdata= 'h0;
    #20 rst_n = 'b0;
    #20 rst_n = 'b1; 
    // test one, wait 5 cycles 
    //byte always = oxf
    // while, test write twice:
    //1. write phase , wait for 5 cycles
    //2. write config, wait for5 cycles 
    // write phrase to 1 
    #16 rd= 'b0; wr= 'b1; bytes= 'hf;addr= 'h1;wdata= 'h1000a;
    #10  rd= 'b0; wr= 'b0; bytes= 'hf;addr= 'h0;wdata= 'h0;
    //wait 5 cycles, write sin config to 0x0
    #50 rd= 'b0; wr= 'b1; bytes= 'hf;addr= 'h0;wdata= 'h00000001;
     #10  rd= 'b0; wr= 'b0; bytes= 'hf;addr= 'h0;wdata= 'h0;
    //wait 5 + 30 cycles , read data
    #350  rd= 'b1; wr= 'b0; bytes= 'hf;addr= 'h2;wdata= 'h0;
     #10  rd= 'b0; wr= 'b0; bytes= 'hf;addr= 'h0;wdata= 'h0;

     //test 2 
     #100 rd= 'b0; wr= 'b1; bytes= 'hf;addr= 'h1;wdata= 'h10014;
    #10  rd= 'b0; wr= 'b0; bytes= 'hf;addr= 'h0;wdata= 'h0;
    //wait 5 cycles, write sin config to 0x0
    #50 rd= 'b0; wr= 'b1; bytes= 'hf;addr= 'h0;wdata= 'h00000001;
     #10  rd= 'b0; wr= 'b0; bytes= 'hf;addr= 'h0;wdata= 'h0;
    //wait 5 + 30 cycles , read data
    #350  rd= 'b1; wr= 'b0; bytes= 'hf;addr= 'h2;wdata= 'h0;
     #10  rd= 'b0; wr= 'b0; bytes= 'hf;addr= 'h0;wdata= 'h0;
     //test 3
      #100 rd= 'b0; wr= 'b1; bytes= 'hf;addr= 'h1;wdata= 'h1000a;
     #10  rd= 'b0; wr= 'b0; bytes= 'hf;addr= 'h0;wdata= 'h0;
    //wait 5 cycles, write sin config to 0x0
     #50 rd= 'b0; wr= 'b1; bytes= 'hf;addr= 'h0;wdata= 'h00000101;
     #10  rd= 'b0; wr= 'b0; bytes= 'hf;addr= 'h0;wdata= 'h0;
    //wait 5 + 30 cycles , read data
     #350  rd= 'b1; wr= 'b0; bytes= 'hf;addr= 'h2;wdata= 'h0;
     #10  rd= 'b0; wr= 'b0; bytes= 'hf;addr= 'h0;wdata= 'h0;
     //test 4
      #100 rd= 'b0; wr= 'b1; bytes= 'hf;addr= 'h1;wdata= 'h10014;
     #10  rd= 'b0; wr= 'b0; bytes= 'hf;addr= 'h0;wdata= 'h0;
    //wait 5 cycles, write sin config to 0x0
     #50 rd= 'b0; wr= 'b1; bytes= 'hf;addr= 'h0;wdata= 'h00000101;
     #10  rd= 'b0; wr= 'b0; bytes= 'hf;addr= 'h0;wdata= 'h0;
    //wait 5 + 30 cycles , read data
     #350  rd= 'b1; wr= 'b0; bytes= 'hf;addr= 'h2;wdata= 'h0;
     #10  rd= 'b0; wr= 'b0; bytes= 'hf;addr= 'h0;wdata= 'h0;
   
end
endmodule