module slave (
    input  wire        clk      ,   
    input  wire        rst_n    ,
    // res to master 
    output reg         a_ready  ,// done 
    // m tells s, if the data in channel-A is valid 
    input  wire        a_valid  ,  
    // datas 
    input  wire [3:0]  a_opcode ,
    input  wire [3:0]  a_mask   ,
    input  wire [3:0]  a_address,
    input  wire [31:0] a_data   ,
    // m tells s , if m is available 
    input  wire        d_ready  ,
    // s tells m, if the data in channel-D is valid 
    output reg         d_valid  ,
    // data in channel-D 
    output reg  [3:0]  d_opcode ,//done
    output reg  [31:0] d_data   ,
    // data to cordic module 
    output reg         reg_wr   ,
    output reg         reg_rd   ,
    output reg  [3:0]  reg_byte ,
    output reg  [3:0]  reg_addr ,
    output reg  [31:0] reg_wdata,
    // res from cordic 
    input  wire [31:0] reg_rdata
);

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)               a_ready <= 1'b0;
    else                      a_ready <= d_ready;
end

// send data to cordic 
// write enable 
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)              reg_wr<= 1'b0;
    else if (a_valid && a_opcode== 4'h0) reg_wr <= 1'b1;
    else if  (a_valid && a_opcode== 4'h1) reg_wr <= 1'b1;
    else                      reg_wr<= 1'b0;
end
//read enable 
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)              reg_rd<= 1'b0;
    else if (a_valid && a_opcode==  4'h4) reg_rd <= 1'b1;
    else                      reg_rd<= 1'b0;
end
//byte 
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)                 reg_byte <= 4'h0;
    else if (a_valid )          reg_byte <= a_mask;
    else                        reg_byte <= 4'h0;  
end
//addr 
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)               reg_addr <= 4'h0;
    else if (a_valid ) reg_addr <=a_address;
    else                      reg_addr <= 4'h0;  
end
//reg_write data 
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)      reg_wdata <= 32'h0;
    else if (a_valid && a_opcode==4'b0) reg_wdata<=a_data ;
    else if (a_valid && a_opcode==4'b0) reg_wdata<=a_data ;
    else             a_data <= 32'h0;  
end
//data to cordic finished 
// channel d optcode , ack message 

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)                    d_opcode <= 4'h0;
    else if (a_valid && a_opcode==4'b0) d_opcode <= 4'h0;//(&cpu-byte==4'b1111)
    else if (a_valid && a_opcode==4'b1) d_opcode <= 4'h0;
    else if (a_valid && a_opcode==4'h4) d_opcode <= 4'h1;
    else                           a_opcode <= 4'h0;
end
//d data 
always @ (posedge clk or negedge rst_n) begin
     if (~rst_n)      d_data <= 32'h0;
    else if () a_data <= reg_rdata;
    else             a_data <= 32'h0;  
end
// d valid 
endmodule