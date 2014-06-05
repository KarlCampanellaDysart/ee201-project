/*
	Reference: FPGA prototyping, Pong P. Chu, 2008
	Implemented by: Jacob Roth
*/

module uart_rx
	(
		input wire clk, reset,
		input wire rx, clock_enable,
		output reg rx_done,
		output [7:0] dout
	);
	
	// UART configuration.. This is custom and not full protocol and does not parity
	
	localparam
		DBIT = 8,		// #data size, 1 byte
		SB_TICK = 16;	// #ticks for a stop bit. This means the stop signal is 1 bit
		

		
	reg [3:0] s_reg = 8'b0;	// Sample counter register. Each bit is sampled 16 times.
	reg [2:0] n_reg = 8'b0;	// Bit counter register. There are 8bits in each transmission
	reg [7:0] b_reg = 8'b0;	// Bit data shift register. Holds the received data bits.
	assign dout = b_reg;

	// FSM
	localparam [3:0]
		IDLE	= 4'b0001,
		START	= 4'b0010,
		DATA	= 4'b0100,
		STOP	= 4'b1000;
	
	// State register for FSM
	reg [3:0] state = IDLE;

	always @(posedge clk)
	begin: FSM
		if (reset)
			begin
				state <= IDLE;
				s_reg <= 4'bXXXX;
				n_reg <= 3'bXXX;
				b_reg <= 8'bXXXX_XXXX;
				rx_done <=1'b0;
			end
		else begin
			case (state)
			
				IDLE:
					begin
						s_reg <= 4'b0000;
						n_reg <= 3'b000;
						rx_done <= 1'b0;
						b_reg <= 8'b0000_0000;
						if( ~rx )						// This is sampled a synchronously because the clocks between the sender/received are assumed to be out of sync.	
							state <= START;			// NSL
					end
				
				START:
					begin
						if ( clock_enable) 
						begin
							s_reg <= s_reg + 1'b1;
							
							if ( s_reg == 15 )		// There are 16 samples per bit. Start signal is one bit low.
								begin
									state	<= DATA;		// NSL
									s_reg	<= 0;
									n_reg	<= 0;
								end
						end
					end
				
				DATA:
					begin
						if ( clock_enable )
						begin
							s_reg <= s_reg + 1'b1;
							
							if (s_reg == 10)						// Sample at the 12th read. Must do this because we start get the start bit async.
								b_reg <= {rx, b_reg[7:1]};		// Shift register
							
							if (s_reg == 15 )
								begin
									s_reg <= 0;
									n_reg <= n_reg + 1'b1;
								end
							
							if ( s_reg == 15 && n_reg == (DBIT - 1 ))
								begin
									rx_done <= 1'b1;
									state <= STOP;			// NSL
								end
						end
					end
					
				STOP:
					begin
						rx_done <= 1'b0;
						if( clock_enable )
						begin
							s_reg <= s_reg + 1'b1;

							if( s_reg == (SB_TICK - 1 ))	// Copy the data bits to the output register and set the done flag.
								begin
									state <= IDLE;			// NSL
								end
						end
					end				
			endcase
		end
	end
endmodule