// By: Paul Mobbs
//
`timescale 10 ns / 1 ns
module ram_2d #(parameter DWIDTH=32, HEIGHT=8, WIDTH=8)         
   (input clk,    input rw,    
    input [$clog2(WIDTH)-1:0] waddr,
    input [$clog2(HEIGHT)-1:0] haddr,
    input [DWIDTH-1:0] datain,    
    output reg [DWIDTH-1:0] dataout
   );

reg [DWIDTH-1:0] ram  [0:HEIGHT-1] [0:WIDTH-1] ;

always @(posedge clk) 
  if (rw) dataout<= ram[haddr][waddr];
  else ram[haddr][waddr] <= datain;

endmodule

