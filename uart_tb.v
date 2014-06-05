`timescale 1ns / 1ps
module uart_tb;
	parameter CLK_PERIOD = 10;
	parameter DIVISOR = 55;
	parameter D_BITS = 6;

	reg clk_tb,reset_tb,rx_tb;
	wire tx_tb;
	wire [7:0] dout_tb;
	reg [7:0]  din_tb;
	wire empty_tb,full_tb,clock_enable_tb;
	
	reg flag_tb= 1'b0;
	
	uart uart_io
	(
		.clk(clk_tb),
		.reset(reset_tb),
		.rx_pin(rx_tb),
		.rd(flag_tb),
		.tx_pin(tx_tb),
		.wr(flag_tb),
		.rx_empty(empty_tb),
		.tx_full(full_tb),
		.din(dout_tb),
		.dout(dout_tb)	
	);
	
	clock_enable #(.M(DIVISOR), .N(D_BITS)) baud_115
	(
		.clk(clk_tb),
		.reset(reset_tb),
		.q(),
		.clock_enable(clock_enable_tb)
	);
	


initial
	begin: STIMULUS
		rx_tb = 1'b1;
		@(negedge reset_tb);
		@(posedge clock_enable_tb)
			#1;
			Send_Bits(8'b1111_0000);
		//@(posedge clock_enable_tb);
		//	#1;
		//	Send_Bits(8'b0000_1111);
		@(posedge clock_enable_tb);
			#1;
		@(posedge clk_tb);
			#1;
		@(negedge full_tb);
		
		$stop;
	end
always @(posedge clk_tb)
	begin: LOOPBACK
		if( reset_tb )
			flag_tb <= 1'b0;
		else begin
			if( ~empty_tb && ~full_tb )
				flag_tb <= 1'b1;
			else
				flag_tb <= 1'b0;
		end
	end
integer S,B;
task Send_Bits;
	input [7:0] bit;
	begin
		for ( S = 0; S <= 16; S = S + 1 ) //START BIT
			begin
				@(posedge clock_enable_tb)
					#5;
					rx_tb = 0;
			end
		
		for ( B = 0; B <= 7 ; B = B + 1 )//DATA BITS
			begin
				for ( S = 0; S < 16 ; S = S + 1 )
				begin
					@(posedge clock_enable_tb)
					#1;
					rx_tb = bit[B];
				end
			end
		
		for ( S = 0; S < 32; S = S + 1 ) //STOP BIT
			begin
				@(posedge clock_enable_tb)
					#1;
					rx_tb = 1;
			end
		
	end
endtask
	
initial
	begin: CLOCK_GENERATOR
		clk_tb=0;
		forever
			begin
				#(CLK_PERIOD/2) clk_tb = ~clk_tb;
			end
	end

initial
	begin  : RESET_GENERATOR
		reset_tb = 1;
		#(2 * CLK_PERIOD) reset_tb = 0;
	end
	
endmodule