`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: EE201 @ USC spring 2014
// Engineer:   Joel Elder
// 
// Create Date:    20:44:21 04/27/2014 
// Design Name: 	
// Module Name:    IO 
// Project Name:   Robot controller
// Target Devices:   FPGA robotic remote
// Description:   Uses an FPGA to take keyboard commands and send a signal through 
//						a wireless connection (via com port) to another FPGA that is programmed 
//				 		to take the wireless signal and perform commands via robotic interface.
//
// Dependencies: a serial interfaced wireless antenna, keyboard, VGA monitor, 
// 					and secondary project FPGA robotic remote
//
// Revision:  there were a lot of revisions.  this one works.
// 
//
//////////////////////////////////////////////////////////////////////////////////
module IO
	(
		input rx,
		input wire clk, reset,
		input wire PS2KD, PS2KC,
		input wire scrn_sw,
//		input wire btnl,btnr,
//		output	An3, An2, An1, An0,			       	// 4 anodes
//		output	Ca, Cb, Cc, Cd, Ce, Cf, Cg,       	// 7 cathodes
//		output	Dp,                                 	// Dot Point Cathode on SSDs
		output tx,

		//vga display stuff
		output wire hsync, vsync,
		output wire [2:0] rgb,
		input wire [2:0] vga_control
    );
	
; 
	wire [7:0] ps2_dout;
	wire ps2_rx_done;
	wire empty;
	wire [7:0] ps2_burst_dout;
	wire [7:0] ascii;
	wire [7:0] rcv_ascii;	
	reg [7:0] kbdata = 8'b0000_0000;
	reg [7:0] rxdata =8'b0;
	reg ps2_done = 1'b0;
	reg rd_uart = 1'b0;
	reg burst_out = 1'b0;
	reg [2:0] vga_in = 3'b000;
	reg [2:0] vga_in2 = 3'b000;
	

//-----------------------------------------------
//instantiate the ps2 controller and the wireless
//-----------------------------------------------
	
	ps2_rx ps2_rx 
		(
			.clk(clk), 
			.reset(reset), 
			.rx_en(1'b1),
			.ps2d(PS2KD), 
			.ps2c(PS2KC),
			.rx_done_tick(ps2_rx_done), 
			.dout(ps2_dout)
		);
/*	
	fifo_buffer ps2_burst_fifo
		(
			.clk(clk),
			.reset(reset),
			.rd(rd_uart),
			.wr(ps2_done),
			.empty(empty_rx),
			.full(full_rx),
			.din(ascii),
			.dout(ps2_burst_dout)
		);
*/		
	uart uart_115
		(
			.clk(clk), 
			.reset(reset),
			.rx_pin(rx),			// rx pin
			.rd(rd_uart),					// we read the data from fifo
//			.wr(burst_out),
			.wr(ps2_done),			// we put some data for tx fifo
//			.wr(ps2_rx_done),
			.din(ascii),			// data for transmission. send to fifo_tx.
//			.din(ps2_burst_dout),
//			.din(ps2_dout),
			
			.rx_empty(empty),
			.tx_full(),
			.tx_pin(tx),			// tx transmission pin and rw done
			.dout(rcv_ascii)					// Incoming data

		);
	
	
	text_screen_top vga_screen 
	(
			.clk(clk), .reset(reset),
			.scrn1(vga_in),
			.scrn2(vga_in2),
			.scrn_sel(scrn_sw),
			.sw(ascii[6:0]),//kb data
			.sw2(rxdata[6:0]),///recived data
			.hsync(hsync), .vsync(vsync),
			.rgb(rgb)
	);
	
//reg [7:0] I;

localparam
	INIT = 'b0001,	
	IDLE = 'b0010,
	ONE = 'b0100,
	TWO = 'b1000;

	reg [3:0] state = INIT;
	
always @(posedge clk)
begin
	case (state)
	INIT:
		begin
			ps2_done <= 1'b0;
			vga_in <= 3'b000;

			state <= IDLE;
		end
	IDLE:
		begin
			ps2_done <= 1'b0;
			vga_in <= 3'b000;
			if (ps2_rx_done) //a character received from the ps2 mod
				begin
					state <= ONE;
					kbdata <= ps2_dout;					

				end
		end
	ONE:
		begin
			if (ps2_rx_done) //a character received from the ps2 mod
				begin
					vga_in <= 3'b100;
					state <= TWO;
				end
		end
	TWO:
		begin
			vga_in <= 3'b000;
			if (ps2_rx_done)
				begin
						ps2_done <= 1'b1;
						state <= INIT;
						vga_in <= 3'b001;		
				end
		end

	endcase
end
localparam
	RX_IDLE =   'b00001,
	RX_READ =   'b00010,
	RX_SHIFT =  'b00100,
	RX_SHIFT2 = 'b01000,
	RX_SHIFT3 = 'b10000;
	
	reg [4:0] rx_state = RX_IDLE;
	

always @(posedge clk)
begin
	case( rx_state )
				RX_IDLE:
					begin
						rd_uart <= 1'b0;
						vga_in2 <= 3'b000;
						if ( ~empty  )
							rx_state <= RX_READ;
					end
				RX_READ:
					begin
						if (~empty) 
							begin				// Need to recheck because there is a delay in the signal
							rd_uart <= 1'b1;
							rxdata <= rcv_ascii;							
							rx_state <= RX_SHIFT;
							end 
						else
							rx_state <= RX_IDLE;					// NSL: go back to idle because fifo is empty
					end
				RX_SHIFT:
					begin
						vga_in2 <= 3'b100;
						rd_uart <= 1'b0;
						rx_state <= RX_SHIFT2;
					end
				RX_SHIFT2:
					begin
						vga_in2 <= 3'b000;
						rx_state <= RX_SHIFT3;
					end
				RX_SHIFT3:
					begin
						vga_in2 <= 3'b001;
						rx_state <= RX_IDLE;
					end
				
	endcase
end
//---------------------
//  KB to ASCII
//---------------------

hex_to_ascii kb_to_ascii
	(
		.key_code(kbdata), 
		.ascii_code(ascii)
	);
	

endmodule
