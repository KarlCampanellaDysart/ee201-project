`timescale 1ns / 1ps
/*
	Reference: none
	Implemented by: Jacob Roth
*/
module fifo_buffer_tb;
parameter CLK_PERIOD = 10;

reg clk_tb,reset_tb,rd_tb,wr_tb;
reg [7:0] data_read_tb, data_write_tb;

wire empty_tb, full_tb;
wire [7:0] fifo_dout_tb;

fifo_buffer UUT
	(
		.clk(clk_tb),
		.reset(reset_tb),
		.rd(rd_tb),
		.wr(wr_tb),
		.empty(empty_tb),
		.full(full_tb),
		.din(data_write_tb),
		.dout(fifo_dout_tb)
	);
	
initial
	begin: STIMULUS
	rd_tb = 0;
	wr_tb = 0;
	data_write_tb = 8'h00;
	@(negedge reset_tb);		// wait for reset to be done
	@(posedge clk_tb);
		#1;
		data_write_tb = 8'h01;
		wr_tb = 1;
	@(posedge clk_tb);
		#1;
		data_write_tb = data_write_tb +1;
	@(posedge clk_tb);
		#1;
		rd_tb = 1;
	@(posedge clk_tb);
		#1;
		wr_tb = 0;	
	end

initial
	begin: CLOCK_GENERATOR
		clk_tb=0;
		forever
			begin
				#(CLK_PERIOD/2) clk_tb = ~clk_tb;
			end
	end
initial
	begin: RESET_GENERATOR
		reset_tb = 1;
		#(2 * CLK_PERIOD) reset_tb = 0;
	end
	
endmodule