`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/08/2026 07:07:38 PM
// Design Name: 
// Module Name: compression_loop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module compression_loop(
    input [31:0] h0,
    input [31:0] h1,
    input [31:0] h2,
    input [31:0] h3,
    input [31:0] h4,
    input [31:0] h5,
    input [31:0] h6,
    input [31:0] h7,
    input [31:0] k,
    input [31:0] w,
    input clk,
    input start,
    output [31:0] a,
    output [31:0] b,
    output [31:0] c,
    output [31:0] d,
    output [31:0] e,
    output [31:0] f,
    output [31:0] g,
    output [31:0] h,
    output ready
    );
endmodule
