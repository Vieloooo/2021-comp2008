
module div_as (
    input  wire       clk  ,
    input  wire       rst_n,
    input  wire [7:0] x    ,
    input  wire [7:0] y    ,
    input  wire       start,
    output wire [7:0] z2   ,
    output wire  [7:0] r2 ,
    output wire        busy2  
);
    reg rs = 'b0;
    reg buzy = 'b0;
    reg [7:0] z= 'b0;
    assign z2= z; 
    assign busy2= buzy;
    reg [14:0] xi= 15'b0;
    reg [7:0]  yi = 8'b0;
    reg [7:0]  cnt = 'b1;
   
    always @(posedge clk)begin
        if (busy2=='b1)begin
           cnt= cnt << 1;
        end else begin
            cnt='b1;
        end
    end
    //xi , yi , z1 r1 buzy 
    always @(posedge clk )begin
    if (~rst_n) begin 
        xi = 'b0;
        yi = 'b0; 
        z  = 'b0;
        buzy = 'b1;
    end 
    else begin 
    if (start=='b1 && buzy == 'b0)begin
            //read + - 
            z[7] = x[7]^y[7];
            rs = x[7];
            // be busy , get y 
            buzy = 'b1;
            // xi <<1
            yi[6:0]=y[6:0];
            xi[14:8]= 'b0;
            xi[7:1]=x[6:0];
            xi[14:7]= xi[14:7]-yi;
        end 
            if (cnt=='b1) begin
            end else if (cnt=='b0)begin
                buzy= 'b0;
            end else if (cnt==8'b10000000)begin
                if (xi[14]=='b1)begin
                    xi[14:7]= xi[14:7]+yi;
                end else begin
                    z[0]='b1;
                   // xi[14:7]= xi[14:7]-yi;
                end   
            end else begin
                if (xi[14]=='b1)begin
                    z[0]='b0;
                    //xi[14:7]= xi[14:7]+yi;
                    z[6:0] = z[6:0]<<1;
                    xi= xi<<1;
                    xi[14:7]= xi[14:7]+yi;
                end else begin
                    z[0]='b1;
                    xi= xi<<1;
                    z[6:0] = z[6:0]<<1;
                    xi[14:7]= xi[14:7]-yi;
                end   
            end      
    end 
        
    end
      assign r2[6:0]=xi[13:7];
  assign r2[7]= rs; 

    
endmodule

module div_rr (
    input  wire       clk  ,
    input  wire       rst_n,
    input  wire [7:0] x    ,
    input  wire [7:0] y    ,
    input  wire       start,
    output wire [7:0] z1   ,
    output wire  [7:0] r1   ,
    output wire        busy1     
);
    reg buzy = 'b0;
    reg [7:0] z= 'b0;
    assign z1= z; 
    assign busy1= buzy;
    reg [14:0] xi= 15'b0;
    reg [7:0]  yi = 8'b0;
    reg [7:0]  cnt = 'b1;
    reg rs = 'b0 ; 
   
    always @(posedge clk)begin
        if (busy1=='b1)begin
           cnt= cnt << 1;
        end else begin
            cnt='b1;
        end
    end
    //xi , yi , z1 r1 buzy 
    always @(posedge clk )begin
    if (~rst_n) begin 
        xi = 'b0;
        yi = 'b0; 
        z = 'b0;
         buzy= 'b0;
    end 
    else begin 
    if (start=='b1 && buzy == 'b0)begin
            //read + - 
            z[7] = x[7]^y[7];
            rs = x[7];
            // be busy , get y 
            buzy = 'b1;
            // xi <<1
            yi[6:0]=y[6:0];
            xi[14:8]= 'b0;
            xi[7:1]=x[6:0];
            xi[14:7]= xi[14:7]-yi;
        end 
            if (cnt=='b1) begin
            end else if (cnt=='b0)begin
                buzy= 'b0;
            end else if (cnt==8'b10000000)begin
                if (xi[14]=='b1)begin
                    xi[14:7]= xi[14:7]+yi;
                end else begin
                    z[0]='b1;
                end   
            end else begin
                if (xi[14]=='b1)begin
                z[0]='b0;
                xi[14:7]= xi[14:7]+yi;
                   z[6:0] = z[6:0]<<1;
                    xi= xi<<1;
                    xi[14:7]= xi[14:7]-yi;
                end else begin
                    z[0]='b1;
                   xi= xi<<1;
                   z[6:0] = z[6:0]<<1;
                  xi[14:7]= xi[14:7]-yi;
                end   
            end      
    end 
    end
  assign r1[6:0]=xi[13:7];
  assign r1[7]= rs; 
        
endmodule