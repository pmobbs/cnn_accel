// CNN Accelerator Compute unit
// Compute each feature layer by taking DEPTH coefficients at once and
// multiplying them each by the input data value. Results of multiplication
// are then summed to produce DEPTH outputs.
// 
// By: Paul Mobbs

module cnn_compute #(parameter DWIDTH=32, HEIGHT=28, WIDTH=28, DEPTH=8) ( 
  input clk,
  input reset_n,
  
  input en,
  input sof,
  input [DWIDTH-1:0] data,
  input [(DWIDTH*DEPTH)-1:0] c_data,
  output [(DWIDTH*DEPTH)-1:0] data_out);

  reg en_d;
  // Delay enable to match data from mem
  always @ (posedge clk) begin
    en_d <= en;
  end

  // Following code implements: accum += coeff*data for each layer
  genvar i;
  generate
	for (i = 0; i < DEPTH; i = i + 1) begin : comp
	
		wire [15:0] mpy_result = data[7:0] * c_data[((i+1)*DWIDTH)-25:i*DWIDTH]; // multiply image by coeffs

		reg [DWIDTH-1:0] accum;
		always @ (posedge clk) begin
			if(reset_n == 1'b0 || sof == 1'b1)
				accum <= 0;
			else begin
				if (en_d == 1'b1)
					accum <= accum + mpy_result[15:8];
			end
		end

		assign data_out[((i+1)*DWIDTH)-1:i*DWIDTH] = accum; 

	end
  endgenerate



endmodule
