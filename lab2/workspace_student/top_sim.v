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
    .wdata(wdata)
    .rdata_v(rdata_v),
    .rdata(rdata)
);
always #5 clk = ~clk;
initial begin
    // start rst 
    #10 rst_n = 'b0;
    #20 rst_n = 'b1; 
    // test one, 
    #6 rd= 'b0; wr= 'b1; bytes= 'hf;addr= 'h0;wdata= 'hab;
    #50  rd= 'b1; wr= 'b0; bytes= 'hf;addr= 'hab;
end