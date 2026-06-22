`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/08/2026 07:07:38 PM
// Design Name: 
// Module Name: message_schedule
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


module message_schedule(
    input [511:0] in,
    input start,
    input clk,
    input rst_n,
    output [31:0] w_out,
    output reg w_valid,
    output reg done
    );

localparam  IDLE  = 0,
            RUNNING = 1,
            DONE = 2;

reg [1:0] state;
reg [31:0] w [0:63];
wire [31:0] s0;
wire [31:0] s1;
wire [31:0] rotateright_7;
wire [31:0] rotateright_18;
wire [31:0] shiftright_3;
wire [31:0] rotateright_17;
wire [31:0] rotateright_19;
wire [31:0] shiftright_10;


integer i;
integer counter;

assign w_out = w[counter-16]; 

assign rotateright_7 = {w[counter-15][6:0], w[counter-15][31:7]};
assign rotateright_18 = {w[counter-15][17:0], w[counter-15][31:18]};
assign shiftright_3 = {3'd0, w[counter-15][31:3]};
assign rotateright_17 = {w[counter-2][16:0], w[counter-2][31:17]};
assign rotateright_19 = {w[counter-2][18:0], w[counter-2][31:19]};
assign shiftright_10 = {10'd0, w[counter-2][31:10]};
assign s0 = rotateright_7 ^ rotateright_18 ^ shiftright_3;
assign s1 = rotateright_17 ^ rotateright_19 ^ shiftright_10;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 64; i = i + 1) begin
            w[i] = 32'b0;
        end
        done <= 0;
        state <= IDLE;
        counter <= 16;
        w_valid <= 0;
    end else begin
        case (state)
            IDLE: begin
                if (start) begin
                    for (i = 0; i < 16; i = i + 1) begin
                        w[i] <= in[(15-i)*32 +: 32];
                    end
                    w_valid <= 1;
                    state <= RUNNING;
                end else begin
                    w_valid <= 0;
                end
                done <= 0;
            end
            
            RUNNING: begin
                w[counter] <= w[counter-16] + s0 + w[counter-7] + s1;
                counter <= counter + 1;
                if (counter < 63) begin
                    state <= RUNNING;
                end else begin
                    state <= DONE;
                end
            end
            
            DONE : begin
                counter <= counter + 1;
                if (counter < 80) begin
                    state <= DONE;
                end else begin
                    counter <= 16;
                    state <= IDLE;
                    done <= 1;
                end
            end
        endcase
    end
end
    
endmodule
