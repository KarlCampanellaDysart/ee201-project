/*
	Reference:	http://en.wikipedia.org/wiki/FIFO
				http://en.wikipedia.org/wiki/Circular_buffer
				
	Implemented by: Jacob Roth
*/

module fifo_buffer
	#(
	parameter	Bits  = 8,		// One location is is a byte
				Width = 4		// width needed to hold the address location
	)
	(
		input wire clk, reset,
		input wire rd, wr,		// Tells the FIFO what operation to perform
		input wire [Bits-1:0] din,
		
		output reg empty, full,	// Status flags
		output [Bits-1:0] dout
	);
	
	// Data Registers
	reg [Bits-1:0] data_reg [0:2**Width-1];		// 2^(Width)-1 cells BITS wide
	reg [Width-1:0] rd_loc = {Width{ 1'b0 }};		// Location of current read
	reg [Width-1:0] wr_loc = {Width{ 1'b0 }};		// Location of current read
	
		
	// FSM
	localparam
		INIT = 0,
		RUN	 = 1;
		
	// State Register
	reg state = INIT;
	// Always have the next address handy
	wire [Width-1:0] rd_loc_next = rd_loc + 1;
	wire [Width-1:0] wr_loc_next = wr_loc + 1;
	
	assign dout = data_reg[rd_loc];// READ
	
	always @(posedge clk) 
	begin: FSM
		if( reset ) begin
			state <= INIT;	// Inital state
			rd_loc <= 1'bX;
			wr_loc <= 1'bX;
			begin: IGNORE_DATA
				integer i;
				for (i=0; i < 2**Width; i = i + 1)  // Keep the value
					data_reg[i] <= {Bits{1'bX}};
			end
		end
		else case (state)
			INIT:
				begin
					rd_loc <= 1'b0;
					wr_loc <= 1'b0;
					full <= 1'b0;
					empty <=1'b1;
					
					begin: RESET_DATA
						integer i;
						for (i=0; i < 2**Width; i = i + 1)  // Keep the value
							data_reg[i] <= {Bits{ 1'b0 }};
					end

					state <= RUN;	// NSL
				end
			RUN:
				begin
					if( wr && ~full)
						data_reg[wr_loc] <= din;	// WRITE
					case ( {rd,wr} )
						2'b01:
							begin: WRITE
								if( ~full ) begin
									wr_loc <=  wr_loc_next;
									empty <= 1'b0;
									
								if( wr_loc_next == rd_loc )
									full <= 1'b1;
								end
									
							end
						2'b10:
							begin: READ
								if( ~empty ) begin
									full <= 1'b0;
									rd_loc <= rd_loc_next;
									
									if( rd_loc_next == wr_loc )
										empty <= 1'b1;
								end									
							end
						2'b11:
							begin: READ_WRITE
								wr_loc <=  wr_loc_next;
								rd_loc <= rd_loc_next;
							end
					endcase
				end
			default: state <= INIT;
		endcase
	end
	
endmodule
	