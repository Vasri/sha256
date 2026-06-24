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
    input [31:0] k,
    input [31:0] w,
    input w_valid,
    input clk,
    input rst_n,
    output [255:0] hash,
    output reg done
    );
    
localparam  [255:0] STARTING_HASH = {32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a, 32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19};


reg [31:0] h [0:7];
reg [31:0] working [0:7];
reg w_valid_d;

wire [31:0] s1;
wire [31:0] ch;
wire [31:0] temp1;
wire [31:0] s0;
wire [31:0] maj;
wire [31:0] temp2;

integer i;

assign s1 = {working[4][5:0], working[4][31:6]} ^ {working[4][10:0], working[4][31:11]} ^ {working[4][24:0], working[4][31:25]};
assign ch = (working[4] & working[5]) ^ ((~working[4]) & working[6]);
assign temp1 = working[7] + s1 + ch + k + w;
assign s0 = {working[0][1:0], working[0][31:2]} ^ {working[0][12:0], working[0][31:13]} ^ {working[0][21:0], working[0][31:22]};
assign maj = (working[0] & working[1]) ^ (working[0] & working[2]) ^ (working[1] & working[2]);
assign temp2 = s0 + maj;

assign hash = {h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7]};

always @(negedge clk or negedge rst_n) begin
    w_valid_d <= w_valid;
    if (!rst_n) begin
        for (i = 0; i < 8; i = i + 1) begin
            working[i] <= STARTING_HASH[(7-i)*32 +: 32];
            h[i] <= STARTING_HASH[(7-i)*32 +: 32];
        end
        done <= 0;
    end else if (w_valid) begin
        working[7] <= working[6];
        working[6] <= working[5];
        working[5] <= working[4];
        working[4] <= working[3] + temp1;
        working[3] <= working[2];
        working[2] <= working[1];
        working[1] <= working[0];
        working[0] <= temp1 + temp2;
    end
    
    if (w_valid_d && !w_valid) begin
        for (i = 0; i < 8; i = i + 1) begin
            h[i] <= h[i] + working[i];
        end
        done <= 1;
    end
    
end


endmodule
