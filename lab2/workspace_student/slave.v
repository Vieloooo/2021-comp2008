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
    output reg         d_valid  ,//done
    // data in channel-D 
    output reg  [3:0]  d_opcode ,//done
    output reg  [31:0] d_data   ,
    // data to cordic module 
    output reg         reg_wr   ,//done
    output reg         reg_rd   ,//done
    output reg  [3:0]  reg_byte ,//done
    output reg  [3:0]  reg_addr ,//done
    output reg  [31:0] reg_wdata,//done
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
    else if (a_valid && a_opcode==4'b1) reg_wdata<=a_data ;
    else             a_data <= 32'h0;  
end
//data to cordic finished 
//******************************
// data in channel D 

// intermediate varialbe to delay return 
reg get_done = 1'b1;
reg prev = 'b1; 
always @(posedge clk or negedge) begin 
    if(~rst_n)      prev <- 'b1;
    else prev <= get_done;
always @ (posedge clk or negedge rst_n) begin
   if (~rst_n)                         get_done<= 'b1;
   else if (a_valid && a_opcode==4'h4) get_done<= 'b0;
   else                                get_done <= 'b1;               
end
// channel d optcode , ack message 
// if a_opt is put, return instantly 
// else if a_opt is get, wait cordic for a circle 
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)                    d_opcode <= 4'h0;
    else if (a_valid && a_opcode==4'b0) d_opcode <= 4'h0;
    else if (a_valid && a_opcode==4'b1) d_opcode <= 4'h0;
    else if (get_done & ~prev) d_opcode <= 4'h1;
    else                           a_opcode <= 4'h0;
end
//channel d data, transfer from cordic to master 
// need to wait for cordic to process cordic 
// wait 1 slice 
always @ (posedge clk or negedge rst_n) begin
     if (~rst_n)               d_data <= 32'h0;
    else if (get_done & ~prev)        d_data <= reg_rdata;
    else                       d_data <= 32'h0;  
end
// d valid 
//if put(), return instantly 
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)               d_valid <= 1'b0;
    else if (a_valid && a_opcode==4'b0) d_valid <= 'b0;
    else if (a_valid && a_opcode==4'b1) d_valid <= 1'b0;
    else if (get_done & ~prev)
    else                      a_valid <= 1'b0;
end
//
endmodule
