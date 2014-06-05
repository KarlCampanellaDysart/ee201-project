`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:03:19 04/26/2014 
// Design Name: 
// Module Name:    text_screen_top 
// Project Name: 
// Target Devices: 
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
// reference "Verilog coding by examples for Spartan 3" Listing 9.1, FPGA prototyping, Pong P. Chu, 2008
//
// Implemented by :  Karl Campanella-Dysart
module text_screen_top
   (
    input wire clk, reset,
	input wire scrn_sel,
    input wire [2:0] scrn1,scrn2,
    input wire [6:0] sw,
	input wire [6:0] sw2,
    output wire hsync, vsync,
    output wire [2:0] rgb
   );
	

 
   reg [2:0] rgb_reg;
   reg [2:0] rgb_reg2;
   //first cursor keyboard input
   wire [9:0] pixel_x, pixel_y;
   wire [2:0] rgb_next;
   wire [2:0] rgb_next2;
   
  
   wire [9:0] switch;
   //original code
   //wire video_on, pixel_tick;
   //reg [2:0] rgb_reg;
   //wire [2:0] rgb_next;
   // body
   // instantiate vga sync circuit
   
   //assign pixel_x = {pixel_x1[9:5] , pixel_x2[9:5]};
   //assign pixel_y = {pixel_y1[9:5] , pixel_y2[9:5]};
   
	
   vga_sync vsync_unit
      (.clk(clk), .reset(reset), .hsync(hsync), .vsync(vsync),
       .video_on(video_on), .p_tick(pixel_tick),
       .pixel_x(pixel_x), .pixel_y(pixel_y),.switch(switch)) ;
	
	/////////////////////////////////////////////////////
	/////////////////////////////////////////////////////
		
   // font generation circuit for first cursor
   text_screen_gen text_gen_unit1
      (.clk(clk), .reset(reset), .video_on(video_on),
       .btn(scrn1), .sw(sw), .pixel_x(pixel_x),
       .pixel_y(pixel_y), .text_rgb(rgb_next));
	   
   // font generation circuit for second cursor
   text_screen_gen text_gen_unit2
      (.clk(clk), .reset(reset), .video_on(video_on),
       .btn(scrn2), .sw(sw2),.pixel_x(pixel_x),
       .pixel_y(pixel_y), .text_rgb(rgb_next2));
	   
   // rgb buffer
   always @(posedge clk)
      if (pixel_tick)
	  begin
         rgb_reg <= rgb_next;
		 rgb_reg2 <= rgb_next2;
		end
		 
   assign rgb = scrn_sel ? rgb_reg : rgb_reg2;
   //assign rgb = rgb_reg;
   
endmodule
