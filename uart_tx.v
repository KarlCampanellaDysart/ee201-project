/*
	Reference: FPGA prototyping, Pong P. Chu, 2008
	Implemented by: Jacob Roth
*/

module uart_tx
	(
		input wire clk, reset,
		input wire tx_start, clock_enable,
		input wire [7:0] din,
		output reg tx_done,tx_ack,
		output wire tx
	);
	
	// UART configuration.. This is custom and not full protocol and does not parity
	
	localparam
		DBIT = 8,		// #data size, 1 byte
		SB_TICK = 16;	// #ticks for a stop bit. This means the stop signal is 1 bit
		

		
	reg [3:0] s_reg;	// Sample counter register. Each bit is sampled 16 times.
	reg [2:0] n_reg;	// Bit counter register. There are 8bits in each transmission
	reg [7:0] b_reg;	// Bit data register. Holds the received data bits for transmission.
	reg tx_reg=1'b1;	// Holds the current bit for transmission.
	assign tx = tx_reg;
	

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
				tx_done <=1'b0;
				tx_reg<=1'b1;
				tx_ack <= 1'b0;
			end
		else begin
			case (state)
			
				IDLE:
					begin
						s_reg <= 4'b0000;
						n_reg <= 3'b000;
						tx_done <= 1'b0;
						b_reg <= 8'b0000_0000;
						tx_reg <=1'b1;
						tx_ack <= 1'b0;
						if( tx_start )					// start bit begin
							begin
								state <= START;
								tx_reg<=1'b0;			// start low ports
								b_reg <= din;			// Copy din to the data register
								tx_ack <= 1'b1;		// Got the command
							end
					end
				
				START:
					begin
						tx_ack <= 1'b0;
						if ( clock_enable) 
						begin
							s_reg <= s_reg + 1'b1;
							tx_reg <= 1'b0;
							if ( s_reg == 15 )			// There are 16 samples per bit. Start signal is one bit low.
								begin
									state	<= DATA;			// NSL
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
							tx_reg <= b_reg[n_reg];
							
							if (s_reg == 15 )
								begin
									s_reg <= 0;
									n_reg <= n_reg + 1'b1;
								end
							
							if ( s_reg == 15 && n_reg == (DBIT - 1 ))
								begin
									state <= STOP;				// NSL
								end
						end
					end
					
				STOP:
					begin
						if( clock_enable )
						begin
							s_reg <= s_reg + 1'b1;
							tx_reg <= 1'b1;
							if( s_reg == (SB_TICK - 1 ))	// Copy the data bits to the output register and set the done flag.
								begin
									tx_done <= 1'b1;
									state <= IDLE;				// NSL
								end
						end
					end				
			endcase
		end
	end
	
endmodule