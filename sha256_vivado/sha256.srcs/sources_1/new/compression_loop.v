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
    input clk,
    input start,
    input rst_n,
    output [31:0] hash [0:7],
    output reg ready
    );
    
localparam  START = 0,
            IDLE = 1,
            RUNNING = 2;
            
localparam  [255:0] STARTING_HASH = {32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a, 32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19};

reg [1:0] state;

reg [31:0] h [0:7];
reg [31:0] working [0:7];

wire [31:0] s1;
wire [31:0] ch;
wire [31:0] temp1;
wire [31:0] s0;
wire [31:0] maj;
wire [31:0] temp2;

integer counter;
integer i;

assign s1 = {working[4][5:0], working[4][31:6]} ^ {working[4][10:0], working[4][31:11]} ^ {25'd0, working[4][31:25]};
assign ch = (working[4] & working[5]) ^ ((~working[4]) & working[6]);
assign temp1 = working[7] + s1 + ch + k + w;
assign s0 = {working[0][1:0], working[0][31:2]} ^ {working[0][12:0], working[0][31:13]} ^ {22'd0, working[0][31:22]};
assign maj = (working[0] & working[1]) ^ (working[0] & working[2]) ^ (working[1] & working[2]);
assign temp2 = s0 + maj;

genvar g;
generate
    for (g = 0; g < 8; g = g + 1) begin
        assign hash[g] = h[g] + working[g];
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= START;
        counter <= 0;
        for (i = 0; i < 8; i = i + 1) begin
            working[i] <= 0;
            h[i] <= STARTING_HASH[(7-i)*32 +: 32];
        end
        ready <= 0;
    end else begin
        case (state)
            START: begin
                if (start) begin
                    for (i = 0; i < 8; i = i + 1) begin
                        working[i] <= h[i];
                    end
                    state <= RUNNING;
                end else begin
                    state <= START;
                end
            end
            
            RUNNING: begin
                if (counter < 64) begin
                    working[7] <= working[6];
                    working[6] <= working[5];
                    working[5] <= working[4];
                    working[4] <= working[3] + temp1;
                    working[3] <= working[2];
                    working[2] <= working[1];
                    working[1] <= working[0];
                    working[0] <= temp1 + temp2;
                    counter <= counter + 1;
                    state <= RUNNING;
                end else begin
                    ready <= 1;
                    state <= IDLE;
                end
            end
            
            IDLE: begin
                state <= IDLE;
            end
            
        endcase
    end
end


endmodule
