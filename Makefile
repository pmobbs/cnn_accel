all: simv model

simv: ram_2d.v cnn_accel_fsm.v cnn_compute.v cnn_accel.v tb.v read_image.c  gen_image.c
	vcs -sverilog -full64 ram_2d.v cnn_accel_fsm.v cnn_compute.v cnn_accel.v tb.v read_image.c  gen_image.c -debug_access+r 

model: model.c
	gcc -std=c99 model.c -o model

