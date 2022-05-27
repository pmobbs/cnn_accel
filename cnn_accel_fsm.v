// CNN Accelerator FSM
// Implements a finite state machine for generating addressing and control to
// the memories
//
// By: Paul Mobbs
//

module cnn_accel_fsm #(parameter DWIDTH=32, HEIGHT=240, WIDTH=320) ( 
  input clk,
  input reset_n,
  
  output en_r1_n,
  output [$clog2(WIDTH)-1:0] waddr_r1,
  output [$clog2(HEIGHT)-1:0] haddr_r1,
  //input [DWIDTH-1:0] data_r1,
  //input [DWIDTH-1:0] c_data_r1,
  output reg en_w2_n,
  output reg [$clog2(WIDTH)-1:0] waddr_w2,
  output reg [$clog2(HEIGHT)-1:0] haddr_w2,
  //output [DWIDTH-1:0] data_w2,
  output done);

reg [$clog2(HEIGHT)-1:0] hcount;
reg [$clog2(WIDTH)-1:0] wcount;

//internal FSM state declarations
wire [2:0] NEXT_STATE;
reg [2:0] PRES_STATE;

// State encodings
localparam init = 4'b0001,
           copy_row = 4'b0010,
           next_row = 4'b0100,
           done_state = 4'b1000;

//Combinational logic
function [4:0] fsm;
  input [$clog2(WIDTH)-1:0] fsm_wcount;
  input [$clog2(HEIGHT)-1:0] fsm_hcount;
  input [3:0] fsm_PRES_STATE;
  reg fsm_done;
  reg [3:0] fsm_NEXT_STATE;
begin
  case (fsm_PRES_STATE)
  init: //state = init
  begin
      fsm_done = 1'b0;
      fsm_NEXT_STATE = copy_row;
    end
 copy_row: //state = copy_row
  begin
    if (fsm_wcount == WIDTH-1) 
        begin
        fsm_done = 1'b0;
        fsm_NEXT_STATE = next_row;
        end
    else
        begin
        fsm_done = 1'b0;
        fsm_NEXT_STATE = copy_row;
        end
  end
  next_row: //state = next_row
  begin
    if (fsm_hcount == HEIGHT-1) 
        begin
        fsm_done = 1'b0;
        fsm_NEXT_STATE = done_state;
        end
    else
        begin
        fsm_done = 1'b0;
        fsm_NEXT_STATE = copy_row;
        end
  end
  done_state: //state = done_state
  begin
    fsm_done = 1'b1; // completed
    fsm_NEXT_STATE = init;
  end
endcase
  fsm = {fsm_done, fsm_NEXT_STATE};
end
endfunction

// Use states to generate address and control
always @(posedge clk)
begin
  if (reset_n == 1'b0)
  begin
    en_w2_n <= 1'b1;
    waddr_w2 <= 0;
    wcount <= 0;
    hcount <= 0;
  end
  else 
  begin
	if (PRES_STATE == copy_row) 
	begin
	  wcount <= wcount + 1;
	  en_w2_n <= 1'b0; // delayed write enable
	  waddr_w2 <= wcount; // delayed H write address	
	end
	else
	begin
	  wcount <= 0;
	  en_w2_n <= 1'b1; // no writes
	  waddr_w2 <= 0;
	end
	
	if (PRES_STATE == next_row) 
	begin
	  hcount <= hcount + 1;
	end
  end

end

assign en_r1_n = (PRES_STATE == copy_row ? 1'b0 : 1'b1);
assign waddr_r1 = wcount;
assign haddr_r1 = hcount;
assign haddr_w2 = hcount;	

//Reevaluate combinational logic each time data
//or the present state changes
assign {done, NEXT_STATE} = fsm(wcount, hcount, PRES_STATE);
//clock the state flip-flops.
//use synchronous reset
always @(posedge clk)
begin
  if (reset_n == 1'b0)
    PRES_STATE <=  init;
  else
    PRES_STATE <=  NEXT_STATE;
end
endmodule
