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
    output [31:0] w_out,
    output ready
    );

reg [31:0] w [0:63];

genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin
        always @(posedge clk) begin
            if (start) begin
                w[i] <= in[i*32 +: 32];
            end
        end
    end
endgenerate

always @(posedge clk) begin
    if (start) begin
    end else begin
    end
end
    
endmodule
