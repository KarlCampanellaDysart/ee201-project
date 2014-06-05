/*
	Reference: FPGA prototyping, Pong P. Chu, 2008
	Implemented by: Jacob Roth
*/

module uart
	(
		input wire clk, reset,
		input wire rx_pin,				// rx pin
		input wire rd,					// we read the data from fifo
		input wire wr,					// we put some data for tx fifo
		input wire [7:0] din,			// data for transmission. send to fifo_tx.
		
		output wire rx_empty,tx_full,
		output wire tx_pin,				// tx transmission pin and rw done
		output wire [7:0] dout			// Incoming data
		
	);

localparam
	BAUD	= 115_200,		// Baud Rate for design.
	SYSCLK	= 100_000_000,	// 100Mhz sys clock
	DBIT 	= 8,			// 1 byte data
	SB_TICK = 16,			// stop signal 2 bytes
	DIVISOR = 28,			// sysclk/(16*baud rate) -- 25e6/(16*baud)= 
	D_BITS	= 5;			// bits to hold the divisor
	
   // Signal declaration to copy the buad clock to the uart modules.
   wire clock_enable;
   // Use a clock enable to create the BAUD rate
	clock_enable #(.M(DIVISOR), .N(D_BITS)) baud_115
		(
			.clk(clk),
			.reset(reset),
			.q(),
			.clock_enable(clock_enable)
		);

	// RX Core
	// Local signals
	wire rx_done,tx_done;
	wire empty_rx, full_rx;
	wire empty_tx, full_tx;
	wire tx_ack;
	wire [7:0] rx_dout,rx_din;
	wire [7:0] rx_fifo_dout,rx_fifo_din;
	wire [7:0] tx_dout,tx_din;
	wire [7:0] tx_fifo_dout,tx_fifo_din;
	
	// Copy signals from fifo to core pins
	assign tx_fifo_din = din;
	assign dout = rx_fifo_dout;
	assign rx_empty = empty_rx;
	assign tx_full = full_tx;

	// RX Core
	uart_rx uart_rx_115
		(
			.clk(clk),
			.reset(reset),
			.rx(rx_pin),
			.clock_enable(clock_enable),
			.rx_done(rx_done),
			.dout(rx_fifo_din)
		);
	fifo_buffer uart_rx_fifo
		(
			.clk(clk),
			.reset(reset),
			.rd(rd),
			.wr(rx_done),
			.empty(empty_rx),
			.full(full_rx),
			.din(rx_fifo_din),
			.dout(rx_fifo_dout)
		);
		
	// TX Core
	uart_tx uart_tx_115
		(
			.clk(clk),
			.reset(reset),
			.tx(tx_pin),
			.tx_start(~empty_tx),
			.tx_ack(tx_ack),
			.clock_enable(clock_enable),
			.tx_done(tx_done),
			.din(tx_fifo_dout)
		);
	fifo_buffer /*#(.Width(16), .Bits(8))*/ uart_tx_fifo
		
		(
			.clk(clk),
			.reset(reset),
			.rd(tx_ack),
			.wr(wr),
			.empty(empty_tx),
			.full(full_tx),
			.din(tx_fifo_din),
			.dout(tx_fifo_dout)
		);
endmodule