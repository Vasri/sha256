`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/25/2026 03:26:21 AM
// Design Name: 
// Module Name: tb_sha256_toplevel
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


module tb_sha256_toplevel;

localparam test_input = 512'h68656C6C6F20776F726C648000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000058;

reg [511:0] in;
reg start;
reg clk;
reg rst_n;
wire [255:0] out;
wire done;

sha256_toplevel uut(
    .in(in),
    .start(start),
    .clk(clk),
    .rst_n(rst_n),
    .hash_latched(out),
    .done(done)
);

always #5 clk <= ~clk;

initial begin
    in <= test_input;
    start <= 0;
    clk <= 0;
    rst_n <= 0;
    repeat(5) @(posedge clk);
    rst_n <= 1;
    
    start <= 1;
    @(posedge clk);
    start <= 0;
    
    @(posedge done);
    $finish;
end

endmodule
