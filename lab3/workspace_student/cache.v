`timescale 1ns / 1ps

module cache(
    // 全局信号
    input clk,
    input reset,
    // 从CPU来的访问信号
    input [12:0] raddr_from_cpu,     // CPU來的读地址
    input rreq_from_cpu,            // CPU来的读请求
    // 从下层内存模块来的信号
    input [31:0] rdata_from_mem,     // 内存读取的数据
    input rvalid_from_mem,          // 内存读取数据可用标志
    // 输出给CPU的信号
    output reg [7:0] rdata_to_cpu,      // 输出给CPU的数据
    output reg hit_to_cpu,              // 输出给CPU的命中标志
    // 输出给下层内存模块的信号
    output reg rreq_to_mem,         // 输出给下层内存模块的读请求
    output reg [12:0] raddr_to_mem  // 输出给下层模块的突发传输首地址
    );
    reg [1:0] state ;
    wire [36:0] douta;
    //state machine ready => fetched <=> load 
    always @(posedge clk or posedge reset) begin
      if (reset)  state <= 'b0;
      else if (rreq_from_cpu && state == 0) state <= 1;
      else if (state == 1) begin 
        if (douta[36]==1 && douta[35:32]== raddr_from_cpu[12:9]) state <= 0;
        else state <= 2;
      end 
      else if (state == 2 && rvalid_from_mem) state <= 1; 
    end
    //data to cpu 
    always@(raddr_from_cpu or  douta)begin
      if (raddr_from_cpu[1:0]==0) rdata_to_cpu = douta[7:0];
      else if (raddr_from_cpu[1:0]==1) rdata_to_cpu = douta[15:8];
      else if (raddr_from_cpu[1:0]==2) rdata_to_cpu = douta[23:16];
      else  rdata_to_cpu = douta[31:24];
    end
    // if hit 
    always @(posedge clk or posedge reset) begin
        if (reset) begin 
        hit_to_cpu <= 0;
        end 
        else if (state == 1)begin
            if (douta[36]==1 && douta[35:32]== raddr_from_cpu[12:9]) hit_to_cpu <= 1;
            else hit_to_cpu <= 0;
        end 
        else hit_to_cpu <= 'b0;
    end
    // if load from main memo
     always @(posedge clk or posedge reset) begin
      if (reset)  rreq_to_mem <= 'b0;
      else if(state ==2) rreq_to_mem <= 'b1;
      else rreq_to_mem <= 'b0;
        
    end
    // head addr to main memo
    always @(raddr_from_cpu)begin
      raddr_to_mem = {raddr_from_cpu[12:2],2'b0};
    end
  cache_blk_mem lovelymem (
    .clka(clk),    // input wire clka
    .ena(1'b1),      // input wire ena
    .wea(rvalid_from_mem),      // input wire [0 : 0] wea
    .addra(raddr_from_cpu[8:2]),  // input wire [6 : 0] addra
    .dina( {1'b1,raddr_from_cpu[12:9],rdata_from_mem[31:0]}),    // input wire [36 : 0] dina
    .douta(douta)  // output wire [36 : 0] douta
  );
endmodule
