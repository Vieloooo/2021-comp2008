module div_rr (
    input  wire       clk  ,
    input  wire       rst_n,
    input  wire [7:0] x    ,
    input  wire [7:0] y    ,
    input  wire       start,
    output wire [7:0] z1   ,
    output reg  [7:0] r1   ,
    output reg        busy1     
);

endmodule
