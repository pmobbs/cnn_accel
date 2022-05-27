// CNN Accelerator Top-level
// Instantiates CNN compute, FSM, and memories for coefficients and input image
//
// By: Paul Mobbs
//
module cnn_accel  #(parameter DWIDTH=32, HEIGHT=8, WIDTH=8, DEPTH=8) 
(
  input clk, 
  input reset_n, 
  output done
); 

  wire en_r1_n;
  wire [$clog2(WIDTH)-1:0] waddr_r1;
  wire [$clog2(HEIGHT)-1:0] haddr_r1;
  wire [DWIDTH-1:0] data_r1;
  wire [(DWIDTH*DEPTH)-1:0] c_data_r1; // coefficient data DWIDTH*DEPTH
  wire en_w2_n;
  wire [$clog2(WIDTH)-1:0] waddr_w2;
  wire [$clog2(HEIGHT)-1:0] haddr_w2;
  wire [(DWIDTH*DEPTH)-1:0] data_w2;

  // Instantiate FSM to generate memory addressing and control
  cnn_accel_fsm #(DWIDTH,HEIGHT,WIDTH) fsm ( 
	.clk(clk), 
	.reset_n(reset_n), 
	.en_r1_n(en_r1_n), 
	.haddr_r1(haddr_r1), 
	.waddr_r1(waddr_r1), 
	.en_w2_n(en_w2_n), 
	.haddr_w2(haddr_w2), 
	.waddr_w2(waddr_w2), 
	.done(done) ); 

  // Instantiate image memory 
  // (Note: Image and coeff mem get same addressing)
  ram_2d #(DWIDTH,HEIGHT,WIDTH) mem
   (.clk(clk),    
    .rw(1'b1), // always read
    .waddr(waddr_r1),
    .haddr(haddr_r1),
    .datain(32'h0),
    .dataout(data_r1)
   );

  // Instantiate DEPTH coefficient memories
  genvar i;
  generate
	for (i = 0; i < DEPTH; i = i + 1) begin : coeff
  		// coefficient memory
  		ram_2d #(DWIDTH,HEIGHT,WIDTH) mem
  		 (.clk(clk),    
  		  .rw(1'b1), // always read
  		  .waddr(waddr_r1),
  		  .haddr(haddr_r1),
  		  .datain(32'h0),
  		  .dataout(c_data_r1[((i+1)*DWIDTH)-1:i*DWIDTH]) // insert coeff data into c_data bus
  		 );
	end
  endgenerate

  // Instantiate compute unit
  cnn_compute #(DWIDTH,HEIGHT,WIDTH,DEPTH) comp ( 
  	.clk	(clk),
  	.reset_n(reset_n),
  	.en	(~en_r1_n), // needs to be delayed
	.sof 	(1'b0),
  	.data	(data_r1),
  	.c_data	(c_data_r1),
  	.data_out(data_w2) // need to handle DEPTH number of outputs
  );

  // Output memory (currently unused) 
  //ram_2d #(DWIDTH,HEIGHT,WIDTH) mem2
  // (.clk(clk),    
  //  .rw(en_w2_n), 
  //  .waddr(waddr_w2),
  //  .haddr(haddr_w2),
  //  .datain(data_w2),
  //  .dataout() // output not used
  // );

endmodule
