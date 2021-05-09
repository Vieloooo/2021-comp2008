module div_rr (
    input  wire       clk  ,
    input  wire       rst_n,
    input  wire [7:0] x    ,
    input  wire [7:0] y    ,
    input  wire       start,
    output reg [7:0] z1   ,
    output reg  [7:0] r1   ,
    output reg        busy1     
);
    reg [14:0] xi= 15'b0;
    reg [7:0]  yi = 8'b0;
    reg [6:0]  cnt = 'b1;
    always @(posedge clk)begin
        if (buzy1==1)begin
            cnt<<1;
        end else begin
            cnt='b1;
        end
    end
    //xi , yi , z1 r1 buzy 
    always @(cnt or posedge  start)begin
        if (start=='b1)begin
            //read + - 
            z1[7]<= x[7]^y[7];
            r1[7]<= x[7]^y[7];
            // be busy , get y 
            buzy1 <= 'b1;
            // xi <<1
            yi[6:0]=y[6:0];
            xi[7:1]=x[6:0];
            xi[16:8]<= xi[16:8]-yi
        end else begin
            if (cnt=='b1) begin
                
            end else if (cnt=='b0)begin
                buzy1<= 'b0;
            end else if (cnt==7'b1000000)begin
                if (xi[14]=='b1)begin
                    xi[14:7]<= xi[14:7]+yi;
                end else begin
                    zi[0]='b1;
                    xi[14:7]<= xi[14:7]-yi;
                end   
            end else begin
                if (xi[14]=='b1)begin
                    z1[6:0]<<1;
                    xi<<1;
                    xi[14:7]<= xi[14:7]+yi;
                end else begin
                    zi[0]='b1;
                    xi<<1;
                    z1[6:0]<<1;
                     xi[14:7]<= xi[14:7]-yi;
                end   
            end
        end       
    end
    always @(*) begin
        r1[6:0]=xi[13:7]
    end
endmodule
