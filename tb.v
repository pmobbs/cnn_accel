// CNN Accelerator Testbench
// Instantiates DUT and loads memories for coefficients and input image for DUT 
// to read from
//
// By: Paul Mobbs
//
`timescale 10ns / 1 ns

module testbench(); 
import "DPI" function read_image(output int rgb[], input string fname ); 
import "DPI" function gen_image(input int rgb[] ); 

// Input image WIDTH*HEIGHT, DEPTH layers for each class
localparam WIDTH = 28, 
	   HEIGHT = 28,
	   DEPTH = 4;

reg clk=0;   always #5 clk = !clk ;
reg reset_n; 
wire done; 
int pict [WIDTH*HEIGHT];
int coeff [WIDTH*HEIGHT];
int pict2 [WIDTH*HEIGHT];
integer i,j; 
initial begin
  string infile;

  if($value$plusargs("INFILE=%s", infile))
    $display("INFILE set to %s", infile);
  else
    infile = "pict.bmp";

  reset_n = 0;
  #20

 // Load memory for input image 
 $display("Loading image");
 read_image(pict, infile); 
 for (j=0;j<HEIGHT;j=j+1)
 begin
   for (i=0;i<WIDTH;i=i+1)
   begin 
    dut.mem.ram[j][i] = pict[j*WIDTH+i]; 
   end 
 end

 // Load memories for coefficients
 $display("Loading coeff");
 read_image(coeff, "coeff0.bmp"); 
 for (j=0;j<HEIGHT;j=j+1)
 begin
   for (i=0;i<WIDTH;i=i+1)
   begin 
    dut.coeff[0].mem.ram[j][i] = coeff[j*WIDTH+i]; 
   end 
 end
 read_image(coeff, "coeff1.bmp"); 
 for (j=0;j<HEIGHT;j=j+1)
 begin
   for (i=0;i<WIDTH;i=i+1)
   begin 
    dut.coeff[1].mem.ram[j][i] = coeff[j*WIDTH+i]; 
   end 
 end
 read_image(coeff, "coeff2.bmp"); 
 for (j=0;j<HEIGHT;j=j+1)
 begin
   for (i=0;i<WIDTH;i=i+1)
   begin 
    dut.coeff[2].mem.ram[j][i] = coeff[j*WIDTH+i]; 
   end 
 end
 read_image(coeff, "coeff3.bmp"); 
 for (j=0;j<HEIGHT;j=j+1)
 begin
   for (i=0;i<WIDTH;i=i+1)
   begin 
    dut.coeff[3].mem.ram[j][i] = coeff[j*WIDTH+i]; 
   end 
 end


  
  reset_n = 1; // bring dut out of reset

  $display("Running dut");
 
 @(posedge done); // wait for done
  
  $display("Done signal seen, writing result");

  // Read out accumulators for each class
  $display("coeff0 result: %d", dut.comp.data_out[31:0]);
  $display("coeff1 result: %d", dut.comp.data_out[63:32]);
  $display("coeff2 result: %d", dut.comp.data_out[95:64]);
  $display("coeff3 result: %d", dut.comp.data_out[127:96]);

$finish;

end

  // Instantiate DUT
  cnn_accel #(32,HEIGHT,WIDTH,DEPTH) dut(.clk(clk), .reset_n(reset_n), .done(done)); 

endmodule

