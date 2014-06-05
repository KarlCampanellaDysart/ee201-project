/*
	Reference:  EE201 Labs
	Implemented by: Jacob Roth
*/

module clock_enable
	#(
		parameter	N=4,	// bits in counter
					M=16	// the number of clock divisions
	)
	(
		input wire clk, reset,
		output wire clock_enable,
		output wire [N-1:0] q		// direct output of counter
	);	
	
	reg [N-1:0] cnt;
	
	initial	begin
		cnt = 0;
	end
	// Create the clock enable signal
	assign clock_enable = (cnt == (M-1)) ? 1'b1 : 1'b0;
	// Copy the raw counter to output q
	assign q = cnt;
	
	// Counter for clock enable
	always @(posedge clk)
	begin: CLOCK_ENABLE
		if ( reset )
			begin
				cnt <= 0;
			end
		else
			begin
			if (cnt == (M-1))
				cnt <= 0;
			else
				cnt <= cnt + 1'b1;
			end
	end

	
endmodule