module master (
    //req from cpu 
    input  wire        clk        ,
    input  wire        rst_n      ,
    input  wire        cpu_wr     ,
    input  wire        cpu_rd     ,
    input  wire [3:0]  cpu_byte   ,
    input  wire [3:0]  cpu_addr   ,
    input  wire [31:0] cpu_wdata  ,
    // res(read data) to cpu when cpu askes to read
    output wire        cpu_rdata_v,// if data is valid 
    output wire [31:0] cpu_rdata  ,
    // s tells m, if channel-A is ready for revieve data 
    input  wire        a_ready    ,
    // req to slave 
    output reg         a_valid    ,  
    output reg  [3:0]  a_opcode   ,
    output reg  [3:0]  a_mask     ,
    output reg  [3:0]  a_address  ,
    output reg  [31:0] a_data     ,
    output reg         d_ready    ,
    // res from the slave, in channel-D
    input  wire        d_valid    ,
    input  wire [3:0]  d_opcode   ,
    input  wire [31:0] d_data     ,
    // master tells cpu 
    //if the communication between m and s (A-D)is over. 
    output reg         trans_over
);

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)               d_ready <= 1'b0;
    else if (cpu_wr | cpu_rd) d_ready <= 1'b1;
end

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)               a_valid <= 1'b0;
    else if (cpu_wr | cpu_rd) a_valid <= 1'b1;
    else                      a_valid <= 1'b0;
end

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)                    a_opcode <= 4'h0;
    else if (cpu_wr & (&cpu_byte)) a_opcode <= 4'h0;//(&cpu-byte==4'b1111)
    else if (cpu_wr)               a_opcode <= 4'h1;
    else if (cpu_rd)               a_opcode <= 4'h4;
    else                           a_opcode <= 4'h0;
end

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)               a_mask <= 4'h0;
    else if (cpu_wr | cpu_rd) a_mask <= cpu_byte;
    else                      a_mask <= 4'h0;  
end

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)               a_address <= 4'h0;
    else if (cpu_wr | cpu_rd) a_address <= cpu_addr;
    else                      a_address <= 4'h0;
end

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)      a_data <= 32'h0;
    else if (cpu_wr) a_data <= cpu_wdata;
    else             a_data <= 32'h0;  
end
//wait for res from slave, then send new res back to cpu 
reg rd_period;
reg trans_over_ff;
//save the transferation status previous
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) trans_over_ff <= 1'b0;
    else        trans_over_ff <= trans_over;
end
// if 2
wire trans_over_pos = trans_over & ~trans_over_ff;

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)              rd_period <= 1'b0;
    else if (trans_over_pos) rd_period <= 1'b0;
    else if (cpu_rd)         rd_period <= 1'b1;
end

assign cpu_rdata_v = rd_period & d_valid;

assign cpu_rdata = d_data;

always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)                 trans_over <= 1'b1;
    else if (a_ready & a_valid) trans_over <= 1'b0;
    else if (d_ready & d_valid) trans_over <= 1'b1;
end

endmodule
