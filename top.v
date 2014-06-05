`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:54:59 04/23/2014 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices:   a whole lot of MEEEEEEEEEEEEEEEEEE
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top
	(
	
	input rx,
	input scrn_sw,
	input wire clk, reset,
	input wire PS2KD, PS2KC,
//	input wire btnl,btnr,
//	output	An3, An2, An1, An0,			       	// 4 anodes
//	output	Ca, Cb, Cc, Cd, Ce, Cf, Cg,       	// 7 cathodes
//	output	Dp,                                 	// Dot Point Cathode on SSDs
	output tx,
	
	output wire hsync, vsync,
	output wire [2:0] rgb,
	input wire [2:0] vga_control
    );
	 

	/////////////////////////////////////////////////////
	// Begin clock division
	parameter N = 1;	// parameter for clock division
	reg clk_half;
	reg [N-1:0] count;
	always @ (posedge clk) begin
		count <= count + 1'b1;
		clk_half <= count[N-1];
	end
	// End clock division
	/////////////////////////////////////////////////////
	
	
	IO IO
	(
	
		.rx(rx),
		.scrn_sw(scrn_sw),
		.clk(clk_half), .reset(reset),
		.PS2KD(PS2KD), .PS2KC(PS2KC),
//		.btnl(btnl),
//		.btnr(btnr),
//		.An3(An3), .An2(An2), .An1(An1), .An0(An0),			    // 4 anodes
//		.Ca(Ca), .Cb(Cb), .Cc(Cc), .Cd(Cd), .Ce(Ce), .Cf(Cf), .Cg(Cg),       	// 7 cathodes
//		.Dp(Dp),                                // Dot Point Cathode on SSDs
		.tx(tx),
		
		.hsync(hsync), .vsync(vsync),
		.rgb(rgb),
		.vga_control(vga_control)
	);

endmodule
